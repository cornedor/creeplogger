// Bindings for react-hook-form.
//
// These replace @greenlabs/ppx-rhf, which only publishes an x86-64 Linux binary and so
// cannot run on arm64 Linux. `register` returns the props react-hook-form wants spread
// onto an input (name, onChange, onBlur, ref), typed as domProps so it can be spread in
// JSX. The field name must match a key of the form's inputs record.

type registerOptions = {required: bool}

type formMethods<'inputs> = {
  register: (string, registerOptions) => JsxDOM.domProps,
  handleSubmit: ('inputs => unit) => JsxEvent.Form.t => unit,
  reset: unit => unit,
}

@module("react-hook-form") external useForm: unit => formMethods<'inputs> = "useForm"
