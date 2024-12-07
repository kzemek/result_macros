defmodule Result do
  @moduledoc """
  Documentation for Result.
  """

  @type t(error, value) :: Result.Error.t(error) | Result.Ok.t(value)

  @doc """
  See `Result.Ok.of/1`
  """
  defmacro ok(value) do
    quote bind_quoted: [value: value] do
      require Result.Ok
      Result.Ok.of(value)
    end
  end

  @doc """
  See `Result.Error.of/1`
  """
  defmacro error(value) do
    quote bind_quoted: [value: value] do
      require Result.Error
      Result.Error.of(value)
    end
  end

  @doc """
  See `Result.Operators.from/2`
  """
  defmacro from(arg1, arg2) do
    quote bind_quoted: [arg1: arg1, arg2: arg2] do
      require Result.Operators
      Result.Operators.from(arg1, arg2)
    end
  end

  # Operators

  @doc """
  See `Result.Operators.fold/1`
  """
  defmacro fold(result) do
    quote bind_quoted: [result: result] do
      require Result.Operators
      Result.Operators.fold(result)
    end
  end

  @doc """
  See `Result.Operators.map/2`
  """
  defmacro map(result, f) do
    quote bind_quoted: [result: result, f: f] do
      require Result.Operators
      Result.Operators.map(result, f)
    end
  end

  @doc """
  See `Result.Operators.map2/3`
  """
  defmacro map2(result1, result2, f) do
    quote bind_quoted: [result1: result1, result2: result2, f: f] do
      Result.Operators.map2(result1, result2, f)
    end
  end

  @doc """
  See `Result.Operators.map_error/2`
  """
  defmacro map_error(result, f) do
    quote bind_quoted: [result: result, f: f] do
      require Result.Operators
      Result.Operators.map_error(result, f)
    end
  end

  @doc """
  See `Result.Operators.catch_error/3`
  """
  defmacro catch_error(result, expected_error, f) do
    quote bind_quoted: [result: result, expected_error: expected_error, f: f] do
      require Result.Operators
      Result.Operators.catch_error(result, expected_error, f)
    end
  end

  @doc """
  See `Result.Operators.catch_all_errors/2`
  """
  defmacro catch_all_errors(result, f) do
    quote bind_quoted: [result: result, f: f] do
      require Result.Operators
      Result.Operators.catch_all_errors(result, f)
    end
  end

  @doc """
  See `Result.Operators.perform/2`
  """
  defmacro perform(result, f) do
    quote bind_quoted: [result: result, f: f] do
      require Result.Operators
      Result.Operators.perform(result, f)
    end
  end

  @doc """
  See `Result.Operators.and_then/2`
  """
  defmacro and_then(result, f) do
    quote bind_quoted: [result: result, f: f] do
      require Result.Operators
      Result.Operators.and_then(result, f)
    end
  end

  @doc """
  See `Result.Operators.and_then_x/2`
  """
  defmacro and_then_x(results, f) do
    quote bind_quoted: [results: results, f: f] do
      require Result.Operators
      Result.Operators.and_then_x(results, f)
    end
  end

  @doc """
  See `Result.Operators.with_default/2`
  """
  defmacro with_default(result, default) do
    quote bind_quoted: [result: result, default: default] do
      require Result.Operators
      Result.Operators.with_default(result, default)
    end
  end

  @doc """
  See `Result.Operators.resolve/1`
  """
  defmacro resolve(result) do
    quote bind_quoted: [result: result] do
      require Result.Operators
      Result.Operators.resolve(result)
    end
  end

  @doc """
  See `Result.Operators.retry/4`
  """
  defmacro retry(result, f, count, timeout \\ 1000) do
    quote bind_quoted: [result: result, f: f, count: count, timeout: timeout] do
      require Result.Operators
      Result.Operators.retry(result, f, count, timeout)
    end
  end

  @doc """
  See `Result.Operators.error?/1`
  """
  defmacro error?(result) do
    quote bind_quoted: [result: result] do
      require Result.Operators
      Result.Operators.error?(result)
    end
  end

  @doc """
  See `Result.Operators.ok?/1`
  """
  defmacro ok?(result) do
    quote bind_quoted: [result: result] do
      require Result.Operators
      Result.Operators.ok?(result)
    end
  end

  # Calculations

  @doc """
  See `Result.Calc.r_and/2`
  """
  defmacro r_and(r1, r2) do
    quote bind_quoted: [r1: r1, r2: r2] do
      require Result.Calc
      Result.Calc.r_and(r1, r2)
    end
  end

  @doc """
  See `Result.Calc.r_or/2`
  """
  defmacro r_or(r1, r2) do
    quote bind_quoted: [r1: r1, r2: r2] do
      require Result.Calc
      Result.Calc.r_or(r1, r2)
    end
  end

  @doc """
  See `Result.Calc.product/1`
  """
  defmacro product(list) do
    quote bind_quoted: [list: list] do
      require Result.Calc
      Result.Calc.product(list)
    end
  end

  @doc """
  See `Result.Calc.sum/1`
  """
  defmacro sum(list) do
    quote bind_quoted: [list: list] do
      require Result.Calc
      Result.Calc.sum(list)
    end
  end
end
