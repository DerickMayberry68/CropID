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

interface SprayNotifyPayload {
  spray_plan_id?: unknown;
  farmer_id?: unknown;
  field_id?: unknown;
  dangerous_adjacent_field_ids?: unknown;
  chemical_names?: unknown;
}

interface AffectedField {
  id: string;
  farmer_id: string;
  name: string;
  visibility: "anonymous" | "public";
}

interface ProfileContact {
  id: string;
  email: string | null;
  phone_number: string | null;
  full_name: string | null;
  farm_name: string | null;
}

interface NotificationInsert {
  recipient_farmer_id: string;
  sender_farmer_id: string;
  spray_plan_id: string;
  affected_field_id: string;
  affected_field_name: string;
  sender_farm_name: string;
  dangerous_chemical_names: string[];
  spray_scheduled_date: string | null;
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
    const payload = await req.json() as SprayNotifyPayload;

    const sprayPlanId = requiredString(
      payload.spray_plan_id,
      "spray_plan_id",
    );
    const farmerId = requiredString(payload.farmer_id, "farmer_id");
    const fieldId = requiredString(payload.field_id, "field_id");

    if (farmerId !== user.id) {
      throw new HttpError(403, "Farmer identity does not match the session");
    }

    const { data: plan, error: planError } = await admin
      .from("spray_plans")
      .select("id, farmer_id, field_id, scheduled_date")
      .eq("id", sprayPlanId)
      .eq("farmer_id", user.id)
      .single();

    if (planError || !plan) {
      throw new HttpError(404, "Spray plan not found");
    }
    if (plan.field_id !== fieldId) {
      throw new HttpError(400, "Field does not match the spray plan");
    }

    const adjacentFieldIds = stringList(
      payload.dangerous_adjacent_field_ids,
      100,
    );
    if (adjacentFieldIds.length === 0) {
      return jsonResponse({
        notified: 0,
        sms_sent: 0,
        email_sent: 0,
        channel_errors: [],
      });
    }

    const { data: affectedFields, error: fieldError } = await admin
      .from("fields")
      .select("id, farmer_id, name, visibility")
      .in("id", adjacentFieldIds)
      .neq("farmer_id", user.id)
      .neq("visibility", "private");

    if (fieldError) throw fieldError;

    const { data: chemicalLinks, error: chemicalLinkError } = await admin
      .from("spray_plan_chemicals")
      .select("chemical_id")
      .eq("spray_plan_id", plan.id);

    if (chemicalLinkError) throw chemicalLinkError;

    const chemicalIds = [
      ...new Set(
        (chemicalLinks ?? []).map((link) => link.chemical_id as string),
      ),
    ];
    let chemicalNames: string[] = [];
    if (chemicalIds.length > 0) {
      const { data: chemicals, error: chemicalError } = await admin
        .from("chemicals")
        .select("name")
        .in("id", chemicalIds);
      if (chemicalError) throw chemicalError;
      chemicalNames = (chemicals ?? []).map((chemical) => chemical.name);
    }
    if (chemicalNames.length === 0) {
      chemicalNames = stringList(payload.chemical_names, 30);
    }

    const { data: senderProfile, error: senderError } = await admin
      .from("profiles")
      .select("farm_name, full_name, email")
      .eq("id", user.id)
      .single();

    if (senderError || !senderProfile) {
      throw new HttpError(404, "Farmer profile not found");
    }

    const senderName = senderProfile.farm_name ??
      senderProfile.full_name ??
      "A neighbor";

    const candidateNotifications: NotificationInsert[] =
      ((affectedFields ?? []) as AffectedField[]).map((field) => ({
        recipient_farmer_id: field.farmer_id,
        sender_farmer_id: user.id,
        spray_plan_id: plan.id,
        affected_field_id: field.id,
        affected_field_name: field.name,
        sender_farm_name: senderName,
        dangerous_chemical_names: chemicalNames,
        spray_scheduled_date: plan.scheduled_date,
      }));

    if (candidateNotifications.length === 0) {
      return jsonResponse({
        notified: 0,
        sms_sent: 0,
        email_sent: 0,
        channel_errors: [],
      });
    }

    const candidateFieldIds = candidateNotifications.map(
      (notification) => notification.affected_field_id,
    );
    const { data: existingNotifications, error: existingError } = await admin
      .from("danger_notifications")
      .select("recipient_farmer_id, affected_field_id")
      .eq("spray_plan_id", plan.id)
      .in("affected_field_id", candidateFieldIds);

    if (existingError) throw existingError;

    const existingKeys = new Set(
      (existingNotifications ?? []).map((notification) =>
        `${notification.recipient_farmer_id}:${notification.affected_field_id}`
      ),
    );
    const pendingNotifications = candidateNotifications.filter((notification) =>
      !existingKeys.has(
        `${notification.recipient_farmer_id}:${notification.affected_field_id}`,
      )
    );

    let notifications: NotificationInsert[] = [];
    if (pendingNotifications.length > 0) {
      const { data: insertedNotifications, error: insertError } = await admin
        .from("danger_notifications")
        .upsert(pendingNotifications, {
          onConflict: "recipient_farmer_id,spray_plan_id,affected_field_id",
          ignoreDuplicates: true,
        })
        .select(
          "recipient_farmer_id, sender_farmer_id, spray_plan_id, affected_field_id, affected_field_name, sender_farm_name, dangerous_chemical_names, spray_scheduled_date",
        );
      if (insertError) throw insertError;
      notifications = (insertedNotifications ?? []) as NotificationInsert[];
    }

    const recipientIds = [
      ...new Set(
        notifications.map((notification) => notification.recipient_farmer_id),
      ),
    ];

    let smsSent = 0;
    let emailSent = 0;
    const channelErrors: Array<Record<string, string>> = [];

    if (recipientIds.length > 0) {
      const { data: recipientProfiles, error: profileError } = await admin
        .from("profiles")
        .select("id, email, phone_number, full_name, farm_name")
        .in("id", recipientIds);

      if (profileError) throw profileError;

      const recipientsById = new Map<string, ProfileContact>(
        ((recipientProfiles ?? []) as ProfileContact[]).map((profile) => [
          profile.id,
          profile,
        ]),
      );

      for (const recipientId of recipientIds) {
        const profile = recipientsById.get(recipientId);
        if (!profile) continue;

        const affectedCount = notifications.filter(
          (notification) => notification.recipient_farmer_id === recipientId,
        ).length;
        const chemicalList = chemicalNames.join(", ") ||
          "unspecified chemicals";
        const scheduleText = plan.scheduled_date
          ? ` Scheduled date: ${plan.scheduled_date}.`
          : "";
        const smsBody =
          `${senderName} plans to spray near ${affectedCount} of your field(s). ` +
          `Chemicals: ${chemicalList}.${scheduleText} View details in CropID.`;
        const emailBody = `Neighbor spray alert from ${senderName}\n\n` +
          `${senderName} plans to spray near ${affectedCount} of your field(s).\n` +
          `Chemicals: ${chemicalList}\n` +
          (plan.scheduled_date
            ? `Scheduled date: ${plan.scheduled_date}\n`
            : "") +
          "Open CropID to review affected fields and notification details.";

        if (profile.phone_number) {
          const smsResult = await sendSmsTwilio(
            profile.phone_number,
            smsBody,
          );
          if (smsResult.sent) {
            smsSent += 1;
          } else if (smsResult.reason !== "twilio_not_configured") {
            channelErrors.push({
              recipient_farmer_id: recipientId,
              channel: "sms",
              reason: smsResult.reason ?? "sms_send_failed",
            });
          }
        }

        if (profile.email) {
          const emailResult = await sendEmailSendGrid({
            to: profile.email,
            subject: "CropID Neighbor Spray Alert",
            text: emailBody,
            replyTo: senderProfile.email,
          });
          if (emailResult.sent) {
            emailSent += 1;
          } else if (emailResult.reason !== "sendgrid_not_configured") {
            channelErrors.push({
              recipient_farmer_id: recipientId,
              channel: "email",
              reason: emailResult.reason ?? "email_send_failed",
            });
          }
        }
      }
    }

    return jsonResponse({
      notified: notifications.length,
      sms_sent: smsSent,
      email_sent: emailSent,
      channel_errors: channelErrors,
    });
  } catch (error) {
    const status = error instanceof HttpError ? error.status : 500;
    const message = error instanceof HttpError
      ? error.message
      : "Internal server error";
    console.error(error);
    return jsonResponse({ error: message }, status);
  }
});
