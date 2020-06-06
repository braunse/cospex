# Copyright (c) 2020 Sebastien Braun
#
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

defmodule CospexTest do
  use ExUnit.Case
  doctest Cospex

  describe "Directive serialization" do
    test "A URL script_src is serialized correctly" do
      csp = Cospex.CSP.new(
        script_src: "http://my-script-src.com"
      )
      stringified = Cospex.CSP.to_string(csp)
      assert stringified == "script-src http://my-script-src.com"
    end

    test "A self script_src is serialized correctly" do
      csp = Cospex.CSP.new(
        script_src: :self
      )
      stringified = Cospex.CSP.to_string(csp)
      assert stringified == "script-src 'self'"
    end

    test "A complex script_src is serialized correctly" do
      csp = Cospex.CSP.new(
        script_src: [sha512: "ABCD"]
      )
      stringified = Cospex.CSP.to_string(csp)
      assert stringified == "script-src 'sha512-ABCD'"
    end

    test "A nonce is added correctly" do
      csp = Cospex.CSP.new(
        script_src: [:self, :nonce]
      )
      stringified = Cospex.CSP.to_string(csp, "ABCD")
      assert Regex.match?(~r"'nonce-ABCD'", stringified)
      assert Regex.match?(~r"'self'", stringified)
    end

    test "Multiple script_srcs are serialized together" do
      csp = Cospex.CSP.new(
        script_src: ["http://my-script-src.com", :self, nonce: "ABCD"]
      )
      stringified = Cospex.CSP.to_string(csp)
      assert String.starts_with?(stringified, "script-src ")
      assert Regex.match?(~r" 'self'( |$)", stringified)
      assert Regex.match?(~r" 'nonce-ABCD'( |$)", stringified)
      assert Regex.match?(~r" http://my-script-src[.]com( |$)", stringified)
    end

    test "Multiple directives are serialized together" do
      csp = Cospex.CSP.new(
        default_src: [:self],
        script_src: [nonce: "ABCD"]
      )
      stringified = Cospex.CSP.to_string(csp)
      assert Regex.match?(~r"(^|;\s*)default-src 'self'(;|$)", stringified)
      assert Regex.match?(~r"(^|;\s*)script-src 'nonce-ABCD'(;|$)", stringified)
    end

    test "Valueless directives are serialized" do
      csp = Cospex.CSP.new(
        upgrade_insecure_requests: true
      )
      stringified = Cospex.CSP.to_string(csp)
      assert stringified == "upgrade-insecure-requests"
    end

    test "Single-value directives are serialized" do
      csp = Cospex.CSP.new(
        sandbox: :allow_forms
      )
      stringified = Cospex.CSP.to_string(csp)
      assert stringified == "sandbox allow-forms"
    end

    test "Dual-use directive is serialized in valueless form" do
      csp = Cospex.CSP.new(
        sandbox: true
      )
      stringified = Cospex.CSP.to_string(csp)
      assert stringified == "sandbox"
    end

    test "Putting nil or false removes a value" do
      csp = Cospex.CSP.new(
        script_src: [:self, nonce: "ABCD"]
      )

      for nothing <- [nil, false] do
        stringified = csp
          |> Cospex.CSP.put(:script_src, nothing)
          |> Cospex.CSP.to_string()
        assert stringified == ""
      end
    end

    test "Putting a value for a valueless directive raises" do
      assert_raise Cospex.ValueError, fn ->
        Cospex.CSP.new(upgrade_insecure_requests: "Yes, please")
      end
    end

    test "Putting is additive" do
      stringified =
        Cospex.CSP.new(script_src: [:self])
        |> Cospex.CSP.put(:script_src, {:nonce, "ABCD"})
        |> Cospex.CSP.to_string()
      assert Regex.match?(~r/'self'/, stringified)
      assert Regex.match?(~r/'nonce-ABCD'/, stringified)
    end

    test "Replacing is not additive" do
      stringified =
        Cospex.CSP.new(script_src: [:self])
        |> Cospex.CSP.replace(:script_src, "data:")
        |> Cospex.CSP.to_string()
      assert Regex.match?(~r/data:/, stringified)
      assert !Regex.match?(~r/'self'/, stringified)
    end
  end
end
