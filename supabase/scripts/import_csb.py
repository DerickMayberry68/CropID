#!/usr/bin/env python3
"""
Import USDA Crop Sequence Boundaries (CSB) into CropID's `csb_fields` table.

Pulls field polygons from USDA NASS's public ArcGIS FeatureServer (reprojected to
WGS84 on the server, so no GDAL/ogr2ogr is required) and either:
  * loads them straight into Supabase  (--load, needs `pip install pg8000`), or
  * writes an idempotent SQL seed file (default; load later with psql).

Network fetches use `curl` (works where urllib TLS is flaky). Standard library
only, except pg8000 when --load is used.

Examples
--------
  # Direct load into Supabase (recommended). Use the SESSION POOLER URI from
  # Dashboard -> Project Settings -> Database -> Connection string (IPv4).
  pip install pg8000
  set SUPABASE_DB_URL=postgresql://postgres.<ref>:<pwd>@aws-0-<region>.pooler.supabase.com:5432/postgres
  python import_csb.py --statefips 05 --cntyfips 111 --load   # test one county first
  python import_csb.py --statefips 05 --load                  # then all of Arkansas

  # SQL-file mode (if you prefer psql / no pg8000):
  python import_csb.py --statefips 05 --split 40000 --out ../seed/csb_ar/arkansas.sql
"""
import argparse
import json
import os
import ssl
import subprocess
import sys
import time
import urllib.parse
import urllib.request

DEFAULT_SERVICE = "Crop_Sequence_Boundary_2022"   # CSB1522 layer (2015-2022)
BASE = "https://pdi.scinet.usda.gov/hosting/rest/services/Hosted/{service}/FeatureServer/0/query"
PAGE = 2000            # server maxRecordCount
COORD_PRECISION = 6    # ~0.1 m
COLS = ("(csb_id, state, county_fips, boundary, boundary_points, acres, "
        "crop_year, predicted_crop_id)")

# USDA Cropland Data Layer class code -> crops.id. The CSB `r22` attribute is
# the 2022 CDL class observed for the field. Codes absent from this map (open
# water, developed land, forest, wetlands, and crops CropID does not track) are
# left NULL rather than guessed at.
CDL_TO_CROP = {
    1: "corn",          2: "cotton",        3: "rice",          4: "sorghum",
    5: "soybeans",      6: "sunflower",     10: "peanuts",      21: "barley",
    22: "wheat",        23: "wheat",        24: "wheat",        27: "rye",
    28: "oats",         31: "canola",       36: "alfalfa",      37: "hay_other",
    41: "sugar_beet",   42: "dry_beans",    43: "potato",       46: "sweet_potato",
    48: "watermelon",   54: "tomatoes",     61: "fallow",       67: "peaches",
    69: "grapes",       74: "pecans",       176: "pasture",
    # Double-crop classes report the dominant cash crop for drift purposes.
    26: "wheat",        225: "corn",        226: "corn",        236: "wheat",
    237: "corn",        238: "cotton",      239: "soybeans",    240: "soybeans",
    241: "corn",        254: "soybeans",
}


# ── USDA FeatureServer paging ────────────────────────────────────────────────
def _unverified_context():
    """TLS context that encrypts but does not verify the certificate chain.

    Corporate proxies and antivirus TLS interception present a substituted CA
    that Python rejects even where the OS accepts it. CSB is public read-only
    reference data, so falling back to an unverified fetch is an acceptable
    trade for being able to import at all.
    """
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    return ctx


def fetch(url, retries=3):
    """GET JSON over whichever transport this machine's TLS setup allows.

    Tries verified urllib, then verified curl, then the unverified variants.
    The USDA endpoint also drops connections under sustained load, so each
    round is retried with a backoff before giving up.
    """
    attempts = (
        ("urllib", True), ("curl", True),
        ("urllib", False), ("curl", False),
    )
    last_error = None
    for round_index in range(retries):
        for transport, verify in attempts:
            try:
                if transport == "urllib":
                    req = urllib.request.Request(
                        url, headers={"User-Agent": "CropID-CSB-Import/1.0"})
                    ctx = None if verify else _unverified_context()
                    with urllib.request.urlopen(req, timeout=120, context=ctx) as resp:
                        return json.loads(resp.read().decode("utf-8"))
                cmd = ["curl", "-s", "--max-time", "120"]
                if not verify:
                    cmd.append("-k")
                out = subprocess.run(cmd + [url], capture_output=True, text=True)
                if out.returncode != 0:
                    raise RuntimeError(f"curl exit {out.returncode}")
                return json.loads(out.stdout)
            except Exception as exc:  # noqa: BLE001 - fall through to next transport
                last_error = exc
        if round_index < retries - 1:
            time.sleep(2 * (round_index + 1))
    raise RuntimeError(f"Could not fetch USDA data: {last_error}")


def query_url(service, where, offset, count):
    params = {
        "where": where,
        "outFields": "csbid,csbacres,statefips,cntyfips,csbyears,r22",
        "outSR": "4326", "f": "geojson", "returnGeometry": "true",
        "orderByFields": "csbid", "resultOffset": str(offset),
        "resultRecordCount": str(count),
    }
    return BASE.format(service=service) + "?" + urllib.parse.urlencode(params)


# ── geometry helpers ─────────────────────────────────────────────────────────
def ring_area(ring):
    a = 0.0
    for (x1, y1), (x2, y2) in zip(ring, ring[1:] + ring[:1]):
        a += x1 * y2 - x2 * y1
    return abs(a) / 2.0


def outer_ring(geom):
    if not geom:
        return None
    t, coords = geom.get("type"), geom.get("coordinates") or []
    if t == "Polygon":
        return coords[0] if coords else None
    if t == "MultiPolygon":
        rings = [poly[0] for poly in coords if poly]
        return max(rings, key=ring_area) if rings else None
    return None


def r(v):
    return round(float(v), COORD_PRECISION)


def to_ewkt(ring):
    pts = [(r(lng), r(lat)) for lng, lat in ring]
    if pts[0] != pts[-1]:
        pts.append(pts[0])
    return "SRID=4326;POLYGON((" + ", ".join(f"{lng} {lat}" for lng, lat in pts) + "))"


def to_boundary_points(ring):
    pts = ring[:-1] if len(ring) > 1 and ring[0] == ring[-1] else ring
    return [{"lat": r(lat), "lng": r(lng)} for lng, lat in pts]


def iter_rows(service, where, limit):
    """Stream converted row dicts from the FeatureServer (bounded memory)."""
    offset, made, seen = 0, 0, set()
    while True:
        page = PAGE if limit is None else min(PAGE, limit - made)
        if page <= 0:
            return
        feats = fetch(query_url(service, where, offset, page)).get("features", [])
        if not feats:
            return
        for f in feats:
            props = f.get("properties", {})
            csbid = props.get("csbid")
            ring = outer_ring(f.get("geometry"))
            if not csbid or csbid in seen or not ring or len(ring) < 4:
                continue
            seen.add(csbid)
            made += 1
            yield {
                "csb_id": csbid,
                "state": props.get("statefips"),
                "county_fips": props.get("cntyfips"),
                "acres": props.get("csbacres"),
                "crop_id": CDL_TO_CROP.get(props.get("r22")),
                "ewkt": to_ewkt(ring),
                "points": json.dumps(to_boundary_points(ring), separators=(",", ":")),
            }
        offset += len(feats)
        print(f"  ...{made} features processed", file=sys.stderr)
        if len(feats) < page:
            return


# ── direct load into Supabase (pg8000) ───────────────────────────────────────
def load_direct(rows, db_url, batch_size=1000, refresh=False):
    try:
        import pg8000.dbapi as pg
    except ImportError:
        sys.exit("Direct load needs pg8000:  pip install pg8000")
    import ssl

    # TLS-encrypt but skip CA chain verification (equivalent to Postgres
    # sslmode=require). The Supabase pooler's chain often fails strict
    # verification on Windows; the connection is still encrypted in transit.
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE

    u = urllib.parse.urlparse(db_url)
    conn = pg.connect(
        user=urllib.parse.unquote(u.username or "postgres"),
        password=urllib.parse.unquote(u.password or ""),
        host=u.hostname, port=u.port or 5432,
        database=(u.path.lstrip("/") or "postgres"),
        ssl_context=ctx,
    )
    cur = conn.cursor()
    row_sql = "(%s,%s,%s,extensions.ST_GeogFromText(%s),%s::jsonb,%s,2022,%s)"
    # Plain imports skip rows already present; --refresh-crops backfills the
    # predicted crop onto boundaries imported before crop codes were fetched.
    conflict = (
        "ON CONFLICT (csb_id) DO UPDATE SET predicted_crop_id = "
        "EXCLUDED.predicted_crop_id"
        if refresh else "ON CONFLICT (csb_id) DO NOTHING"
    )
    total, batch = 0, []

    def flush():
        nonlocal total
        if not batch:
            return
        sql = (f"INSERT INTO csb_fields {COLS} VALUES "
               + ",".join([row_sql] * len(batch))
               + " " + conflict)
        params = []
        for x in batch:
            params += [x["csb_id"], x["state"], x["county_fips"], x["ewkt"],
                       x["points"], (None if x["acres"] is None else float(x["acres"])),
                       x["crop_id"]]
        cur.execute(sql, params)
        conn.commit()
        total += len(batch)
        batch.clear()
        print(f"  loaded {total} rows...", file=sys.stderr)

    try:
        for row in rows:
            batch.append(row)
            if len(batch) >= batch_size:
                flush()
        flush()
    finally:
        cur.close()
        conn.close()
    print(f"Done. Loaded {total} rows into csb_fields.", file=sys.stderr)


# ── SQL-file output ──────────────────────────────────────────────────────────
def sql_literal(s):
    return "'" + str(s).replace("'", "''") + "'"


def write_file(path, subset, chunk):
    with open(path, "w", encoding="utf-8") as fh:
        fh.write(f"-- USDA CSB import ({len(subset)} rows)\n\n")
        for i in range(0, len(subset), chunk):
            fh.write(f"INSERT INTO csb_fields {COLS} VALUES\n")
            vals = []
            for x in subset[i:i + chunk]:
                acres = "NULL" if x["acres"] is None else f"{float(x['acres']):.4f}"
                cty = "NULL" if x["county_fips"] is None else sql_literal(x["county_fips"])
                crop = ("NULL" if x["crop_id"] is None
                        else sql_literal(x["crop_id"]))
                vals.append(
                    f"  ({sql_literal(x['csb_id'])}, {sql_literal(x['state'])}, {cty}, "
                    f"extensions.ST_GeogFromText({sql_literal(x['ewkt'])}), "
                    f"{sql_literal(x['points'])}::jsonb, {acres}, 2022, {crop})")
            fh.write(",\n".join(vals) + "\nON CONFLICT (csb_id) DO NOTHING;\n\n")


def main():
    ap = argparse.ArgumentParser(description="Import USDA CSB into csb_fields.")
    ap.add_argument("--statefips", default="05", help="State FIPS (Arkansas=05)")
    ap.add_argument("--cntyfips", default=None, help="County FIPS, e.g. 111 (Poinsett)")
    ap.add_argument("--service", default=DEFAULT_SERVICE, help="CSB FeatureServer name")
    ap.add_argument("--limit", type=int, default=None, help="Max features")
    ap.add_argument("--load", action="store_true",
                    help="Load straight into Supabase via pg8000 (uses --db-url/SUPABASE_DB_URL)")
    ap.add_argument("--refresh-crops", action="store_true",
                    help="With --load: update predicted_crop_id on boundaries "
                         "that are already imported")
    ap.add_argument("--db-url", default=os.environ.get("SUPABASE_DB_URL"),
                    help="Postgres URI (defaults to $SUPABASE_DB_URL)")
    ap.add_argument("--out", help="Output .sql path (SQL-file mode)")
    ap.add_argument("--chunk", type=int, default=500, help="Rows per INSERT statement")
    ap.add_argument("--split", type=int, default=None, help="Rows per output FILE")
    args = ap.parse_args()

    where = f"statefips='{args.statefips}'"
    if args.cntyfips:
        where += f" AND cntyfips='{args.cntyfips}'"

    rows = iter_rows(args.service, where, args.limit)

    if args.load:
        if not args.db_url:
            sys.exit("Set --db-url or $SUPABASE_DB_URL (session pooler URI from the dashboard).")
        load_direct(rows, args.db_url, refresh=args.refresh_crops)
        return

    if not args.out:
        sys.exit("SQL-file mode needs --out PATH (or use --load).")
    materialized = list(rows)
    if not materialized:
        sys.exit("No features returned — check --statefips/--cntyfips.")
    if args.split:
        base = args.out[:-4] if args.out.lower().endswith(".sql") else args.out
        parts = [materialized[i:i + args.split] for i in range(0, len(materialized), args.split)]
        for n, sub in enumerate(parts, 1):
            write_file(f"{base}.{n:03d}.sql", sub, args.chunk)
            print(f"Wrote {len(sub)} rows -> {base}.{n:03d}.sql", file=sys.stderr)
    else:
        write_file(args.out, materialized, args.chunk)
        print(f"Wrote {len(materialized)} rows -> {args.out}", file=sys.stderr)


if __name__ == "__main__":
    main()
