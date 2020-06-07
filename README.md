# Cospex

## Better Content-Security-Policy for Phoenix apps

Cospex wants to make it easier to use modern
[Content-Security-Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy)
in your
[Phoenix](https://www.phoenixframework.org/)
applications, including with
[Phoenix Live View](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html).

Cospex supports generating a [nonce](https://content-security-policy.com/nonce/) for better security.

## Installation

At the moment, Cospex is not yet in [hex.pm](https://hex.pm), so you would have to add a dependency to this git repository:

```elixir
def deps do
  [
    # ...,
    {:cospex, git: "https://github.com/braunse/cospex.git"},
    # ...,
  ]
```

To enable it, add the Cospex Plug to your router:

```elixir
  pipeline :browser do
    # ...
    plug Cospex.Plug,
      default_src: [:self, :nonce],
      script_src: [:self, :strict_dynamic, :nonce]
  end
```

And further, to output `<script>` and `<link>` tags with the correct nonce,
switch to the helper functions in `Cospex.ViewHelpers`:

```eex
  <%= Cospex.ViewHelpers.style_tag(@conn, "/js/app.css") %>
  <%= Cospex.ViewHelpers.script_tag(@conn, "/js/app.js") %>
```
