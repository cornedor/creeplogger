import { getWebInstrumentations, initializeFaro } from "@grafana/faro-web-sdk";
import { TracingInstrumentation } from "@grafana/faro-web-tracing";
import packageJson from "../../package.json";

var faro = process.env.NEXT_PUBLIC_FARO_URL
  ? initializeFaro({
      url: process.env.NEXT_PUBLIC_FARO_URL,
      app: {
        name: packageJson.name,
        version: packageJson.version,
        environment: "production",
      },

      instrumentations: [
        // Mandatory, overwriting the instrumentations array would cause the default instrumentations to be omitted
        ...getWebInstrumentations(),

        // Initialization of the tracing package.
        // This packages is optional because it increases the bundle size noticeably. Only add it if you want tracing data.
        new TracingInstrumentation(),
      ],
    })
  : undefined;
