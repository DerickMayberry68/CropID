// ============================================================
// CropID Edge Function: contact_crop_duster
// Sends SMS/email to a registered crop duster service on behalf
// of a farmer using Twilio and SendGrid when configured.
//
// Deploy: supabase functions deploy contact_crop_duster
// Required secrets:
// - SUPABASE_URL
// - SUPABASE_SERVICE_ROLE_KEY
// Optional SMS:
// - TWILIO_SID
// - TWILIO_TOKEN
// - TWILIO_FROM_NUMBER
// Optional email:
// - SENDGRID_API_KEY
// - SENDGRID_FROM_EMAIL
// - SENDGRID_FROM_NAME
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface ContactCropDusterPayload {
  service_id: string;
  farmer_id: string;
  field_name: string;
  chemical_names: string[];
  danger_count: number;
  lat?: number;
  lng?: number;
  message?: string;
  send_sms?: boolean;
  send_email?: boolean;
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
    return {
      sent: false,
      reason: `twilio_${response.status}`,
      error: await response.text(),
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
    return {
      sent: false,
      reason: `sendgrid_${response.status}`,
      error: await response.text(),
    };
  }

  return { sent: true };
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    );

    const payload: ContactCropDusterPayload = await req.json();
    const sendSms = payload.send_sms ?? true;
    const sendEmail = payload.send_email ?? true;

    if (!payload.service_id || !payload.farmer_id) {
      return new Response(
        JSON.stringify({ error: "Missing service_id or farmer_id" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    if (!sendSms && !sendEmail) {
      return new Response(
        JSON.stringify({ error: "No delivery channel requested" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        },
      );
    }

    const { data: service, error: serviceErr } = await supabase
      .from("crop_duster_services")
      .select("id, name, phone, email, is_active")
      .eq("id", payload.service_id)
      .eq("is_active", true)
      .single();

    if (serviceErr) throw serviceErr;

    const { data: farmer, error: farmerErr } = await supabase
      .from("profiles")
      .select("id, email, phone_number, full_name, farm_name")
      .eq("id", payload.farmer_id)
      .single();

    if (farmerErr) throw farmerErr;

    const senderName = farmer.farm_name ?? farmer.full_name ??
      "A CropID farmer";
    const chemicalList = payload.chemical_names.length > 0
      ? payload.chemical_names.join(", ")
      : "TBD";
    const locationLink = payload.lat != null && payload.lng != null
      ? `https://maps.google.com/?q=${payload.lat},${payload.lng}`
      : "Coordinates not available";

    const message = payload.message ??
      `Hello,\n\n` +
        `${senderName} needs spray service for field "${payload.field_name}".\n\n` +
        `Location: ${locationLink}\n` +
        `Chemicals: ${chemicalList}\n` +
        `${
          payload.danger_count > 0
            ? `Neighboring at-risk fields: ${payload.danger_count}\n`
            : ""
        }` +
        `Please reply to schedule this request through CropID.\n`;

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
          subject: `CropID Spray Request - ${payload.field_name}`,
          text: message,
          replyTo: farmer.email,
        });
        results.email = emailResult.sent
          ? "sent"
          : emailResult.reason ?? "email_send_failed";
      }
    }

    return new Response(JSON.stringify(results), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    });
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 500,
    });
  }
});
