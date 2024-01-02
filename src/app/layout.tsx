import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Kruiplogger",
  description: "Houd de score bij van je tafelvoetbalwedstrijden",
  robots: "noindex",
  manifest: "/manifest.json",
  icons: {
    apple: [57, 60, 72, 76, 114, 120, 144, 152, 180, 192].map((size) => ({
      url: `/${size}.png`,
      sizes: `${size}x${size}`,
    })),
    icon: {
      sizes: "32x32",
      url: "/32.png",
    },
  },
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
      <body className={inter.className}>{children}</body>
    </html>
  );
}
