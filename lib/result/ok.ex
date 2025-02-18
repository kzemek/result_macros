defmodule Result.Ok do
  @moduledoc """
  A Ok creator
  """

  @type t(val) :: {:ok, val}

  @doc """
  Create Ok result from value

  ## Examples

      iex> Result.Ok.of("a")
      {:ok, "a"}

      iex> Result.Ok.of(12345)
      {:ok, 12345}

  """
  defmacro of(value) do
    quote bind_quoted: [value: value] do
      {:ok, value}
    end
  end
end
