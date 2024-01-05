import { sendDailyUpdate } from "@/helpers/Mattermost.bs.mjs";
import { NextRequest } from "next/server";

export async function GET(request: NextRequest) {
  const authHeader = request.headers.get("authorization");
  if (authHeader !== `Bearer ${process.env.CRON_SECRET}`) {
    return new Response("Unauthorized", {
      status: 401,
    });
  }

  if (request.nextUrl.searchParams.get("send")) {
    await sendDailyUpdate();
    return Response.json({ success: true });
  }

  return Response.json({ success: true });
}
