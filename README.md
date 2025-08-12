This is a [Next.js](https://nextjs.org/) project bootstrapped with [`create-next-app`](https://github.com/vercel/next.js/tree/canary/packages/create-next-app).

## Getting Started

First, run the development server:

```bash
npm install
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) with your browser to see the result.

You can start editing the page by modifying `app/Logger.res`. The page auto-updates as you edit the file.

This project uses:

 - [ReScript](https://rescript-lang.org) 11.0 with @rescript/react and JSX 4 automatic mode
 - Tailwind 3
 - [`next/font`](https://nextjs.org/docs/basic-features/font-optimization) to automatically optimize and load Inter, a custom Google Font.


## Tips

### Fast Refresh & ReScript

Make sure to create interface files (`.resi`) for each `*.res` file.

Fast Refresh requires you to **only export React components**, and it's easy to unintenionally export other values that will disable Fast Refresh (you will see a message in the browser console whenever this happens).

### Why are the generated `.bs.mjs` files tracked in git?

In ReScript, it's a good habit to keep track of the actual JS output the compiler emits. It allows quick sanity checking if we made any changes that actually have an impact on the resulting JS code (especially when doing major compiler upgrades, it's a good way to verify if production code will behave the same way as before the upgrade).

This will also make it easier for your Non-ReScript coworkers to read and understand the changes in Github PRs, and call you out when you are writing inefficient code.

If you want to opt-out, feel free to remove all compiled `.mjs` files within the `src` directory and add `src/**/*.mjs` in your `.gitignore`.


## Learn More

To learn more about Next.js, take a look at the following resources:

- [Next.js Documentation](https://nextjs.org/docs) - learn about Next.js features and API.
- [Learn Next.js](https://nextjs.org/learn) - an interactive Next.js tutorial.

You can check out [the Next.js GitHub repository](https://github.com/vercel/next.js/) - your feedback and contributions are welcome!

## Deploy on Vercel

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js&utm_source=create-next-app&utm_campaign=create-next-app-readme) from the creators of Next.js.

Check out our [Next.js deployment documentation](https://nextjs.org/docs/deployment) for more details.

## Testing

- Run tests: `npm test`
- Run tests with coverage: `npm run test:coverage`

Coverage uses the V8 provider via `@vitest/coverage-v8`.
