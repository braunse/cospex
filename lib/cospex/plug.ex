# Copyright (c) 2020 Sebastien Braun
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule Cospex.Plug do
  @behaviour Plug

  alias Plug.Conn

  def init(options) do
    options = options || []
    {entropy, options} = Keyword.pop(options, :nonce_entropy, 64)

    %{
      nonce_entropy: entropy,
      policy: Cospex.CSP.new(options)
    }
  end

  def call(conn, options) do
    conn
    |> Conn.assign(:cospex_policy, options.policy)
    |> ensure_nonce(options)
    |> render_header()
  end

  defp ensure_nonce(conn, %{nonce_entropy: entropy_bits}) do
    nonce = :crypto.strong_rand_bytes(div(entropy_bits + 7, 8))
    nonce_encoded = Base.encode64(nonce)

    conn
    |> Conn.assign(:cospex_nonce, nonce_encoded)
  end

  defp render_header(conn) do
    Conn.put_resp_header(conn, "content-security-policy", Cospex.CSP.to_string(conn.assigns[:cospex_policy], conn.assigns[:cospex_nonce]))
  end
end
