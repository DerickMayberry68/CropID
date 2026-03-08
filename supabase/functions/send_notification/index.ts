// ============================================================
// CropID Edge Function: send_notification
// Triggered when a spray plan is saved to notify affected farmers.
//
// Deploy: supabase functions deploy send_notification
// Phase 4: optional Twilio + SendGrid fanout to affected farmers
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface SprayNotifyPayload {
  spray_plan_id: string;
  farmer_id: string;
  field_id: string;
  dangerous_adjacent_field_ids: string[];
  chemical_names: string[];
  scheduled_date?: string;
}

interface ProfileContact {
  id: string;
  email: string | null;
  phone_number: string | null;
  full_name: string | null;
  farm_name: string | null;
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
        Body: body,
      }),
    },
  );

  if (!response.ok) {
    const errorText = await response.text();
    return {
      sent: false,
      reason: `twilio_${response.status}`,
      error: errorText,
    };
  }

  return { sent: true };
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

  if (!response.ok) {
    const errorText = await response.text();
    return {
      sent: false,
      reason: `sendgrid_${response.status}`,
      error: errorText,
    };
  }

  return { sent: true };
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const payload: SprayNotifyPayload = await req.json();

    if (!payload.dangerous_adjacent_field_ids?.length) {
      return new Response(JSON.stringify({ message: "No danger fields" }), {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      });
    }

    // Fetch affected fields to find their owners
    const { data: affectedFields, error: fieldErr } = await supabase
      .from("fields")
      .select("id, farmer_id, name")
      .in("id", payload.dangerous_adjacent_field_ids);

    if (fieldErr) throw fieldErr;

    // Fetch sender farm name
    const { data: senderProfile } = await supabase
      .from("profiles")
      .select("farm_name, full_name, email")
      .eq("id", payload.farmer_id)
      .single();

    const senderName = senderProfile?.farm_name ?? senderProfile?.full_name ??
      "A neighbor";

    // Create a notification for each affected farmer
    const notifications = affectedFields
      ?.filter((f) => f.farmer_id !== payload.farmer_id) // don't notify yourself
      .map((f) => ({
        recipient_farmer_id: f.farmer_id,
        sender_farmer_id: payload.farmer_id,
        spray_plan_id: payload.spray_plan_id,
        affected_field_id: f.id,
        affected_field_name: f.name,
        sender_farm_name: senderName,
        dangerous_chemical_names: payload.chemical_names,
        spray_scheduled_date: payload.scheduled_date ?? null,
      })) ?? [];

    if (notifications.length > 0) {
      const { error: insertErr } = await supabase
        .from("danger_notifications")
        .insert(notifications);
      if (insertErr) throw insertErr;
    }

    const recipientIds = [
      ...new Set(notifications.map((n) => n.recipient_farmer_id)),
    ];

    let smsSent = 0;
    let emailSent = 0;
    const channelErrors: Array<Record<string, string>> = [];

    if (recipientIds.length > 0) {
      const { data: recipientProfiles, error: profileErr } = await supabase
        .from("profiles")
        .select("id, email, phone_number, full_name, farm_name")
        .in("id", recipientIds);

      if (profileErr) throw profileErr;

      const recipientsById = new Map<string, ProfileContact>(
        ((recipientProfiles ?? []) as ProfileContact[]).map((
          profile,
        ) => [profile.id, profile]),
      );

      for (const recipientId of recipientIds) {
        const profile = recipientsById.get(recipientId);
        if (!profile) continue;

        const affectedCount = notifications.filter(
          (notification) => notification.recipient_farmer_id === recipientId,
        ).length;
        const chemicalList = payload.chemical_names.join(", ") ||
          "unspecified chemicals";
        const scheduleText = payload.scheduled_date
          ? ` Scheduled date: ${payload.scheduled_date.split("T")[0]}.`
          : "";
        const smsBody =
          `${senderName} plans to spray near ${affectedCount} of your field(s). ` +
          `Chemicals: ${chemicalList}.${scheduleText} View details in CropID.`;
        const emailBody = `Neighbor spray alert from ${senderName}\n\n` +
          `${senderName} plans to spray near ${affectedCount} of your field(s).\n` +
          `Chemicals: ${chemicalList}\n` +
          `${
            payload.scheduled_date
              ? `Scheduled date: ${payload.scheduled_date.split("T")[0]}\n`
              : ""
          }` +
          `Open CropID to review affected fields and notification details.`;

        if (profile.phone_number) {
          const smsResult = await sendSmsTwilio(profile.phone_number, smsBody);
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
            replyTo: senderProfile?.email ?? undefined,
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

    return new Response(
      JSON.stringify({
        notified: notifications.length,
        sms_sent: smsSent,
        email_sent: emailSent,
        channel_errors: channelErrors,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
