import type { Metadata, Viewport } from "next";
import { Inter, Caveat } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

const caveat = Caveat({
  display: "swap",
  subsets: ["latin"],
  weight: "500",
  variable: "--font-caveat",
});

export const metadata: Metadata = {
  title: "Kruiplogger",
  description: "Houd de score bij van je tafelvoetbalwedstrijden",
  robots: "noindex",
  manifest: "/manifest.json",
};

export const viewport: Viewport = {
  initialScale: 1,
  minimumScale: 1,
  maximumScale: 1,
  userScalable: false,
  width: "device-width",
  themeColor: "#242328",
  colorScheme: "dark",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="nl">
      <head>
        <script
          defer
          data-domain="creeplogger.vercel.app"
          src="https://p.cd0.nl/js/script.pageview-props.tagged-events.js"
        ></script>
      </head>
      <body className={inter.className + " " + caveat.variable}>
        {children}
      </body>
    </html>
  );
}
