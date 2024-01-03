import { sendDailyUpdate } from "@/helpers/Mattermost.bs.mjs";
import { NextResponse } from "next/server";

export async function GET() {
  await sendDailyUpdate();

  // @ts-ignore
  return NextResponse.json({ ok: true });
}
