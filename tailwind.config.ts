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
      },
      backgroundImage: {
        "gradient-radial": "radial-gradient(var(--tw-gradient-stops))",
        "gradient-conic":
          "conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))",
        blobs: "url(/BG.png)",
      },
    },
  },
  plugins: [],
};
export default config;
