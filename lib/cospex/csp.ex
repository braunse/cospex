defmodule Cospex.CSP do
  @moduledoc """
    Content-Security-Policy headers are represented as a map
    of directive names to the corresponding values.

    TODO more content here
  """

  @single_value_directives [
    :sandbox,
    :report_uri,
    :report_to,
    :referrer
  ]

  @no_value_directives [
    :sandbox,
    :block_all_mixed_content,
    :upgrade_insecure_requests
  ]

  @unquoted_atoms_directives [
    :sandbox,
    :report_uri,
    :report_to
  ]

  def new(), do: %{}

  def new(kvlist) do
    Enum.reduce(kvlist, new(), fn {key, value}, csp ->
      put(csp, key, value)
    end)
  end

  def put(csp, key, nothing) when nothing == nil or nothing == false do
    Map.delete(csp, key)
  end

  def put(csp, key, value) when key in @single_value_directives do
    Map.put(csp, key, value)
  end

  def put(csp, key, true) when key in @no_value_directives do
    Map.put(csp, key, true)
  end

  def put(_csp, key, _other_value) when key in @no_value_directives do
    raise Cospex.ValueError, "#{key} directive only accepts boolean values"
  end

  def put(csp, key, value) when is_tuple(value) or is_atom(value) or is_binary(value) do
    put(csp, key, [value])
  end

  def put(csp, key, values) do
    Map.update(csp, key, MapSet.new(values), &MapSet.union(&1, MapSet.new(values)))
  end

  def replace(csp, key, value) when key in @single_value_directives or key in @no_value_directives do
    put(csp, key, value)
  end

  def replace(csp, key, value) when is_tuple(value) or is_atom(value) or is_binary(value) do
    replace(csp, key, [value])
  end

  def replace(csp, key, values) do
    Map.put(csp, key, MapSet.new(values))
  end

  def delete(csp, key) do
    Map.delete(csp, key)
  end

  def to_string(csp, nonce \\ nil) do
    csp
    |> Enum.map(&directive_to_string(&1, nonce))
    |> Enum.join("; ")
  end

  defp directive_to_string({_directive, false}, _nonce) do
    nil
  end

  defp directive_to_string({directive, true}, _nonce) when directive in @no_value_directives do
    to_kebab_string(directive)
  end

  defp directive_to_string({directive, value}, nonce) when directive in @single_value_directives do
    "#{to_kebab_string(directive)} #{format_value(directive, value, nonce)}"
  end

  defp directive_to_string({directive, values}, nonce) do
    values_string =
      values
      |> Enum.map(&format_value(directive, &1, nonce))
      |> Enum.filter(&(!is_nil(&1)))
      |> Enum.join(" ")

    "#{to_kebab_string(directive)} #{values_string}"
  end

  defp to_kebab_string(atom) do
    Atom.to_string(atom)
    |> String.replace("_", "-")
  end

  defp format_value(directive, value, _nonce) when is_atom(value) and directive in @unquoted_atoms_directives do
    to_kebab_string(value)
  end

  defp format_value(_directive, :nonce, nonce), do: "'nonce-#{nonce}'"

  defp format_value(_directive, value, _nonce) when is_atom(value)  do
    "'#{to_kebab_string(value)}'"
  end

  defp format_value(_directive, {prefix, suffix}, _nonce) when is_atom(prefix) and is_binary(suffix) do
    "'#{to_kebab_string(prefix)}-#{suffix}'"
  end

  defp format_value(_directive, value, _nonce) when is_binary(value) do
    value
  end

  defp format_value(directive, value, _nonce) do
    raise Cospex.ValueError, "Cannot format unexpected value #{inspect(value)} for #{directive}"
  end
end
