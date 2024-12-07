defmodule Result.Calc do
  @moduledoc """
  Result calculations
  """

  @doc """
  Calculate the AND of two results

  r_and :: Result e1 a -> Result e2 b -> Result [e1, e2] [a, b]

  ## Examples

      iex> Result.Calc.r_and({:ok, 1}, {:ok, 2})
      {:ok, [1, 2]}

      iex> Result.Calc.r_and({:ok, 1}, {:error, 2})
      {:error, [2]}

      iex> Result.Calc.r_and({:error, 1}, {:ok, 2})
      {:error, [1]}

      iex> Result.Calc.r_and({:error, 1}, {:error, 2})
      {:error, [1, 2]}

  """
  defmacro r_and(left, right) do
    quote bind_quoted: [left: left, right: right] do
      case {left, right} do
        {{:ok, val1}, {:ok, val2}} -> {:ok, [val1, val2]}
        {{:ok, _}, {:error, val2}} -> {:error, [val2]}
        {{:error, val1}, {:ok, _}} -> {:error, [val1]}
        {{:error, val1}, {:error, val2}} -> {:error, [val1, val2]}
      end
    end
  end

  @doc """
  Calculate the OR of two results

  r_or :: Result e1 a -> Result e2 b -> Result [e1, e2] [a, b]

  ## Examples

      iex> Result.Calc.r_or({:ok, 1}, {:ok, 2})
      {:ok, [1, 2]}

      iex> Result.Calc.r_or({:ok, 1}, {:error, 2})
      {:ok, [1]}

      iex> Result.Calc.r_or({:error, 1}, {:ok, 2})
      {:ok, [2]}

      iex> Result.Calc.r_or({:error, 1}, {:error, 2})
      {:error, [1, 2]}

  """
  defmacro r_or(left, right) do
    quote bind_quoted: [left: left, right: right] do
      case {left, right} do
        {{:ok, val1}, {:ok, val2}} -> {:ok, [val1, val2]}
        {{:ok, val1}, {:error, _}} -> {:ok, [val1]}
        {{:error, _}, {:ok, val2}} -> {:ok, [val2]}
        {{:error, val1}, {:error, val2}} -> {:error, [val1, val2]}
      end
    end
  end

  @doc """
  Calculate product of Results

  product :: List (Result e a) -> Result (List e) (List a)

  ## Examples

      iex> data = [{:ok, 1}, {:ok, 2}, {:ok, 3}]
      iex> Result.Calc.product(data)
      {:ok, [1, 2, 3]}

      iex> data = [{:error, 1}, {:ok, 2}, {:error, 3}]
      iex> Result.Calc.product(data)
      {:error, [1, 3]}

      iex> data = [{:error, 1}]
      iex> Result.Calc.product(data)
      {:error, [1]}

      iex> data = []
      iex> Result.Calc.product(data)
      {:ok, []}
  """
  defmacro product(list) do
    quote bind_quoted: [list: list] do
      list
      |> Enum.reduce({:ok, []}, fn
        {:ok, val}, {:ok, acc} -> {:ok, [val | acc]}
        {:ok, _val}, {:error, acc} -> {:error, acc}
        {:error, val}, {:ok, _acc} -> {:error, [val]}
        {:error, val}, {:error, acc} -> {:error, [val | acc]}
      end)
      |> then(fn {ok_or_error, acc} -> {ok_or_error, Enum.reverse(acc)} end)
    end
  end

  @doc """
  Calculate sum of Results

  sum :: List (Result e a) -> Result (List e) (List a)

  ## Examples

      iex> data = [{:ok, 1}, {:ok, 2}, {:ok, 3}]
      iex> Result.Calc.sum(data)
      {:ok, [1, 2, 3]}

      iex> data = [{:error, 1}, {:ok, 2}, {:error, 3}]
      iex> Result.Calc.sum(data)
      {:ok, [2]}

      iex> data = [{:error, 1}, {:error, 2}, {:error, 3}]
      iex> Result.Calc.sum(data)
      {:error, [1, 2, 3]}

      iex> data = [{:error, 1}]
      iex> Result.Calc.sum(data)
      {:error, [1]}

      iex> data = []
      iex> Result.Calc.sum(data)
      {:error, []}
  """
  defmacro sum(list) do
    quote bind_quoted: [list: list] do
      list
      |> Enum.reduce({:error, []}, fn
        {:ok, val}, {:ok, acc} -> {:ok, [val | acc]}
        {:ok, val}, {:error, _acc} -> {:ok, [val]}
        {:error, _val}, {:ok, acc} -> {:ok, acc}
        {:error, val}, {:error, acc} -> {:error, [val | acc]}
      end)
      |> then(fn {ok_or_error, acc} -> {ok_or_error, Enum.reverse(acc)} end)
    end
  end
end
