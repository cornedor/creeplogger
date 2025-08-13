import { NextRequest } from "next/server";

let periodOptions = {
  daily: "Daily",
  weekly: "Weekly",
  monthly: "Monthly",
  all: "All",
};

export async function GET(request: NextRequest) {
  const { getDailyOverview, toAPIObject } = await import("@/helpers/Summary.bs.mjs");
  let period = request.nextUrl.searchParams.get("period") ?? "daily";
  if (!(period in periodOptions)) {
    return Response.json({ success: false, message: "Invalid period param" });
  }

  let obj = toAPIObject(
    await getDailyOverview(periodOptions[period as keyof typeof periodOptions])
  );

  return Response.json(obj);
}
