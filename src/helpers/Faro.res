@module("@grafana/faro-web-sdk") @scope(("faro", "api"))
external pushLog: array<string> => unit = "pushLog"

@module("@grafana/faro-web-sdk") @scope(("faro", "api"))
external pushError: array<Exn.t> => unit = "pushError"

@module("@grafana/faro-web-sdk") @scope(("faro", "api"))
external pushEvent: string => unit = "pushEvent"

// type trace = {}
// type tracer = {}
// type context = {}
// type span = {}

// type otel = {
//   trace: trace,
//   context: context,
// }

// @module("@grafana/faro-web-sdk") @scope(("faro", "api"))
// external getOTEL: unit => otel = "getOTEL"

// @send external contextWith: (context, span, unit => unit) => unit = "with"
// @send external activeContext: context => context = "active"

// @send external getTracer: (trace, string) => tracer = "getTracer"

// @send external startSpan: (tracer, string) => tracer = "startSpan"
