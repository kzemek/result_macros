# Result (macro version)

[![CI](https://github.com/kzemek/result_macros/actions/workflows/elixir.yml/badge.svg)](https://github.com/kzemek/result_macros/actions/workflows/ci.yml)
[![Module Version](https://img.shields.io/hexpm/v/result_macros.svg)](https://hex.pm/packages/result_macros)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/result_macros/)
[![License](https://img.shields.io/hexpm/l/result_macros.svg)](https://github.com/kzemek/result_macros/blob/master/LICENSE)

A Result pattern for Elixir.

This is a fork of the [`result`](https://github.com/iodevs/result) library that preserves the same
functions and their semantics, except that everything is implemented as a macro.

I love Rust-like result handling, but incurring a module call overhead every time I'd like to wrap
my values in `{:ok, val}` was too steep a price to pay.

## Installation

The package can be installed by adding `result_macros` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:result_macros, "~> 1.7.2"}
  ]
end
```
