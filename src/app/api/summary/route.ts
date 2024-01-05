import { sendDailyUpdate } from "@/helpers/Mattermost.bs.mjs";
import { getDailyOverview, toAPIObject } from "@/helpers/Summary.bs.mjs";
import { NextRequest } from "next/server";

let periodOptions = {
  daily: "Daily",
  weekly: "Weekly",
  monthly: "Monthly",
};

export async function GET(request: NextRequest) {
  let period = request.nextUrl.searchParams.get("period") ?? "daily";
  if (!(period in periodOptions)) {
    await sendDailyUpdate();
    return Response.json({ success: false, message: "Invalid period param" });
  }

  let obj = toAPIObject(
    await getDailyOverview(periodOptions[period as keyof typeof periodOptions])
  );

  return Response.json(obj);
}
