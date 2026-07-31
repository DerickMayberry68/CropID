import {
  createClient,
  type SupabaseClient,
  type User,
} from "npm:@supabase/supabase-js@2.110.8";

export class HttpError extends Error {
  constructor(
    readonly status: number,
    message: string,
  ) {
    super(message);
    this.name = "HttpError";
  }
}

function getAdminKey(): string {
  const secretKeysJson = Deno.env.get("SUPABASE_SECRET_KEYS");
  if (secretKeysJson) {
    try {
      const secretKeys = JSON.parse(secretKeysJson) as Record<string, unknown>;
      const defaultKey = secretKeys.default;
      if (typeof defaultKey === "string" && defaultKey.length > 0) {
        return defaultKey;
      }
    } catch {
      throw new Error("SUPABASE_SECRET_KEYS is not valid JSON");
    }
  }

  // Supports older local stacks while hosted projects migrate to secret keys.
  const legacyKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (legacyKey) return legacyKey;

  throw new Error("No Supabase admin key is available");
}

export function createAdminClient(): SupabaseClient {
  const url = Deno.env.get("SUPABASE_URL");
  if (!url) throw new Error("SUPABASE_URL is not configured");

  return createClient(url, getAdminKey(), {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

export async function requireAuthenticatedUser(
  req: Request,
  admin: SupabaseClient,
): Promise<User> {
  const authorization = req.headers.get("Authorization");
  const match = authorization?.match(/^Bearer\s+(.+)$/i);
  if (!match) {
    throw new HttpError(401, "Missing bearer token");
  }

  const { data, error } = await admin.auth.getUser(match[1]);
  if (error || !data.user) {
    throw new HttpError(401, "Invalid or expired session");
  }

  return data.user;
}
