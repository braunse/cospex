defmodule Cospex.ViewHelpers do
  use Phoenix.HTML
  alias Phoenix.Controller

  def script_tag(conn, path, integrity \\ nil) do
    path = Controller.endpoint_module(conn).static_path(path)
    nonce = conn.assigns[:cospex_nonce]
    ~E"""
      <script src="<%= path %>" type="text/javascript"<%= nonce_attr(nonce) %><%= sri_attr(integrity) %>></script>
    """
  end

  def style_tag(conn, path, integrity \\ nil) do
    path = Controller.endpoint_module(conn).static_path(path)
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
end
