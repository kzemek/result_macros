defmodule Result.Error do
  @moduledoc """
  A Error creator
  """

  @type t(error) :: {:error, error}

  @doc """
  Create Error result from value

  ## Examples

      iex> Result.Error.of("a")
      {:error, "a"}

      iex> Result.Error.of(12345)
      {:error, 12345}
  """
  defmacro of(value) do
    quote bind_quoted: [value: value] do
      {:error, value}
    end
  end
end
