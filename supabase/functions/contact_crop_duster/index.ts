import {
  createAdminClient,
  HttpError,
  requireAuthenticatedUser,
} from "../_shared/auth.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface ContactCropDusterPayload {
  service_id?: unknown;
  farmer_id?: unknown;
  field_name?: unknown;
  chemical_names?: unknown;
  danger_count?: unknown;
  lat?: unknown;
  lng?: unknown;
  message?: unknown;
  send_sms?: unknown;
  send_email?: unknown;
}

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function requiredString(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim().length === 0) {
    throw new HttpError(400, `Missing ${field}`);
  }
  return value.trim();
}

function stringList(value: unknown, limit: number): string[] {
  if (!Array.isArray(value)) return [];
  return [
    ...new Set(
      value
        .filter((item): item is string => typeof item === "string")
        .map((item) => item.trim())
        .filter(Boolean),
    ),
  ].slice(0, limit);
}

function optionalNumber(value: unknown): number | null {
  return typeof value === "number" && Number.isFinite(value) ? value : null;
}

async function sendSmsTwilio(to: string, body: string) {
  const sid = Deno.env.get("TWILIO_SID");
  const token = Deno.env.get("TWILIO_TOKEN");
  const from = Deno.env.get("TWILIO_FROM_NUMBER");

  if (!sid || !token || !from) {
    return { sent: false, reason: "twilio_not_configured" };
  }

  const response = await fetch(
    `https://api.twilio.com/2010-04-01/Accounts/${sid}/Messages.json`,
    {
      method: "POST",
      headers: {
        Authorization: `Basic ${btoa(`${sid}:${token}`)}`,
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        To: to,
        From: from,
        Body: body.slice(0, 1500),
      }),
    },
  );

  return response.ok
    ? { sent: true }
    : { sent: false, reason: `twilio_${response.status}` };
}

async function sendEmailSendGrid(args: {
  to: string;
  subject: string;
  text: string;
  replyTo?: string | null;
}) {
  const apiKey = Deno.env.get("SENDGRID_API_KEY");
  const fromEmail = Deno.env.get("SENDGRID_FROM_EMAIL");
  const fromName = Deno.env.get("SENDGRID_FROM_NAME") ?? "CropID";

  if (!apiKey || !fromEmail) {
    return { sent: false, reason: "sendgrid_not_configured" };
  }

  const response = await fetch("https://api.sendgrid.com/v3/mail/send", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      personalizations: [{ to: [{ email: args.to }] }],
      from: { email: fromEmail, name: fromName },
      subject: args.subject,
      content: [{ type: "text/plain", value: args.text }],
      ...(args.replyTo ? { reply_to: { email: args.replyTo } } : {}),
    }),
  });

  return response.ok
    ? { sent: true }
    : { sent: false, reason: `sendgrid_${response.status}` };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const admin = createAdminClient();
    const user = await requireAuthenticatedUser(req, admin);
    const payload = await req.json() as ContactCropDusterPayload;

    const serviceId = requiredString(payload.service_id, "service_id");
    const farmerId = requiredString(payload.farmer_id, "farmer_id");
    const fieldName = requiredString(payload.field_name, "field_name")
      .slice(0, 200);

    if (farmerId !== user.id) {
      throw new HttpError(403, "Farmer identity does not match the session");
    }

    const sendSms = payload.send_sms === undefined
      ? true
      : payload.send_sms === true;
    const sendEmail = payload.send_email === true;
    if (!sendSms && !sendEmail) {
      throw new HttpError(400, "No delivery channel requested");
    }

    const { data: service, error: serviceError } = await admin
      .from("crop_duster_services")
      .select("id, name, phone, email, is_active")
      .eq("id", serviceId)
      .eq("is_active", true)
      .single();

    if (serviceError || !service) {
      throw new HttpError(404, "Active crop-duster service not found");
    }

    const { data: farmer, error: farmerError } = await admin
      .from("profiles")
      .select("id, email, phone_number, full_name, farm_name")
      .eq("id", user.id)
      .single();

    if (farmerError || !farmer) {
      throw new HttpError(404, "Farmer profile not found");
    }

    const senderName = farmer.farm_name ??
      farmer.full_name ??
      "A CropID farmer";
    const chemicalNames = stringList(payload.chemical_names, 30);
    const chemicalList = chemicalNames.join(", ") || "TBD";
    const dangerCount = typeof payload.danger_count === "number" &&
        Number.isInteger(payload.danger_count)
      ? Math.max(0, Math.min(payload.danger_count, 100))
      : 0;
    const lat = optionalNumber(payload.lat);
    const lng = optionalNumber(payload.lng);
    const locationLink = lat !== null && lng !== null
      ? `https://maps.google.com/?q=${lat},${lng}`
      : "Coordinates not available";

    const customMessage = typeof payload.message === "string"
      ? payload.message.trim().slice(0, 4000)
      : "";
    const message = customMessage ||
      `Hello,\n\n` +
        `${senderName} needs spray service for field "${fieldName}".\n\n` +
        `Location: ${locationLink}\n` +
        `Chemicals: ${chemicalList}\n` +
        (dangerCount > 0
          ? `Neighboring at-risk fields: ${dangerCount}\n`
          : "") +
        "Please reply to schedule this request through CropID.\n";

    const results = {
      sms: "not_requested",
      email: "not_requested",
      service_name: service.name,
    };

    if (sendSms) {
      if (!service.phone) {
        results.sms = "missing_service_phone";
      } else {
        const smsResult = await sendSmsTwilio(service.phone, message);
        results.sms = smsResult.sent
          ? "sent"
          : smsResult.reason ?? "sms_send_failed";
      }
    }

    if (sendEmail) {
      if (!service.email) {
        results.email = "missing_service_email";
      } else {
        const emailResult = await sendEmailSendGrid({
          to: service.email,
          subject: `CropID Spray Request - ${fieldName}`,
          text: message,
          replyTo: farmer.email,
        });
        results.email = emailResult.sent
          ? "sent"
          : emailResult.reason ?? "email_send_failed";
      }
    }

    return jsonResponse(results);
  } catch (error) {
    const status = error instanceof HttpError ? error.status : 500;
    const message = error instanceof HttpError
      ? error.message
      : "Internal server error";
    console.error(error);
    return jsonResponse({ error: message }, status);
  }
});
