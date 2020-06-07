# Copyright (c) 2020 Sebastien Braun
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Cospex.ViewHelpers do
  use Phoenix.HTML
  alias Phoenix.Controller

  def script_tag(conn, path, integrity \\ :lookup) do
    {path, cached_integrity} = Controller.endpoint_module(conn).static_path(path)
    integrity = use_integrity(integrity, cached_integrity)
    nonce = conn.assigns[:cospex_nonce]
    ~E"""
      <script src="<%= path %>" type="text/javascript"<%= nonce_attr(nonce) %><%= sri_attr(integrity) %>></script>
    """
  end

  def style_tag(conn, path, integrity \\ :lookup) do
    {path, cached_integrity} = Controller.endpoint_module(conn).static_lookup(path)
    integrity = use_integrity(integrity, cached_integrity)
    nonce = conn.assigns[:cospex_nonce]
    IO.inspect %{integrity: integrity}
    ~E"""
      <link rel="stylesheet" href="<%= path %>" type="text/css"<%= nonce_attr(nonce) %><%= sri_attr(integrity) %>>
    """
  end

  defp nonce_attr(_no_nonce = nil), do: ""
  defp nonce_attr(nonce), do: raw(" nonce=\"#{nonce}\"")

  defp sri_attr(_no_integrity = nil), do: ""
  defp sri_attr(integrity), do: raw(" integrity=\"#{integrity}\"")

  defp use_integrity(nil = _specified, _cached), do: nil
  defp use_integrity(:lookup = _specified, cached), do: "sha512-#{cached}"
  defp use_integrity(specified, _cached), do: specified
end
