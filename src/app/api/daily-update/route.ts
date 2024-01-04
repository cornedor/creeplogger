import { sendDailyUpdate } from "@/helpers/Mattermost.bs.mjs";
import { NextRequest, NextResponse } from "next/server";

export async function GET(request: NextRequest) {
  if (request.nextUrl.searchParams.get("send")) {
    await sendDailyUpdate();
    return NextResponse.json({ ok: true });
  }

  // @ts-ignore
  return NextResponse.json({ ok: false });
}
