import type { Config } from "tailwindcss";

const config: Config = {
  content: [
    "./src/pages/**/*.{mjs,js,ts,jsx,tsx,mdx}",
    "./src/components/**/*.{mjs,js,ts,jsx,tsx,mdx}",
    "./src/app/**/*.{mjs,js,ts,jsx,tsx,mdx}",
  ],
  theme: {
    extend: {
      colors: {
        darkbg: "#242328",
        overlay: "rgba(36, 35, 40, 0.7)",
      },
      fontFamily: {
        handwritten: ["var(--font-caveat)"],
      },
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-conic":
          "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
        blobs: "url(/BG.png)",
      },
      gridTemplateRows: {
        user: "66% auto",
      },
      ringColor: {
        blue: "#6ca2ee",
        red: "#ee6c6c",
      },
      ringWidth: {
        6: "6px",
      },
      backdropBlur: {
        overlay: "20px",
      },
      backdropSaturate: {
        overlay: "180%",
      },
    },
  },
  plugins: [],
};
export default config;
