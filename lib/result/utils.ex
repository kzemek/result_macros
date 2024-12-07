defmodule Result.Utils do
  @moduledoc """
  A result utility functions
  """

  defmacro check(result) do
    quote bind_quoted: [result: result] do
      case result do
        {:ok, _} -> result
        {:error, _} -> result
        _ -> raise Result.TypeError, result
      end
    end
  end
end
