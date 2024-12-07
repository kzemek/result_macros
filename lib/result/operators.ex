defmodule Result.Operators do
  @moduledoc """
  A result operators.
  """

  @doc """
  Chain together a sequence of computations that may fail.

  ## Examples

      iex> val = {:ok, 1}
      iex> Result.Operators.and_then(val, fn (x) -> {:ok, x + 1} end)
      {:ok, 2}

      iex> val = {:error, 1}
      iex> Result.Operators.and_then(val, fn (x) -> {:ok, x + 1} end)
      {:error, 1}

  """
  defmacro and_then(result, f) do
    quote bind_quoted: [result: result, f: f] do
      with {:ok, val} <- result, do: f.(val)
    end
  end

  @doc """
  Chain together a sequence of computations that may fail for functions with multiple argumets.

  ## Examples

      iex> args = [{:ok, 1}, {:ok, 2}]
      iex> Result.Operators.and_then_x(args, fn (x, y) -> {:ok, x + y} end)
      {:ok, 3}

      iex> args = [{:ok, 1}, {:error, "ERROR"}]
      iex> Result.Operators.and_then_x(args, fn (x, y) -> {:ok, x + y} end)
      {:error, "ERROR"}

  """
  defmacro and_then_x(args, f) do
    quote bind_quoted: [args: args, f: f] do
      case args do
        [] ->
          {:ok, nil}

        [{:error, reason} | _] ->
          {:error, reason}

        [first_arg | rest_args] ->
          Enum.reduce_while(rest_args, first_arg, fn
            {:ok, val}, {:ok, acc} ->
              {:cont, f.(val, acc)}

            {:error, reason}, _ ->
              {:halt, {:error, reason}}
          end)
      end
    end
  end

  @doc """
  Fold function returns tuple `{:ok, [...]}` if all
  tuples in list contain `:ok` or `{:error, ...}` if
  only one tuple contains `:error`.

  ## Examples

      iex> val = [{:ok, 3}, {:ok, 5}, {:ok, 12}]
      iex> Result.Operators.fold(val)
      {:ok, [3, 5, 12]}

      iex> val = [{:ok, 3}, {:error, 1}, {:ok, 2}, {:error, 2}]
      iex> Result.Operators.fold(val)
      {:error, 1}

  """
  defmacro fold(list) do
    quote bind_quoted: [list: list] do
      with {:ok, acc} <-
             Enum.reduce_while(list, {:ok, []}, fn
               {:ok, val}, {:ok, acc} -> {:cont, {:ok, [val | acc]}}
               {:error, reason}, _ -> {:halt, {:error, reason}}
             end),
           do: {:ok, Enum.reverse(acc)}
    end
  end

  @doc """
  Convert maybe to result type.

  ## Examples

      iex> Result.Operators.from(123, "msg")
      {:ok, 123}

      iex> Result.Operators.from(nil, "msg")
      {:error, "msg"}

      iex> Result.Operators.from(:ok, 123)
      {:ok, 123}

      iex> Result.Operators.from(:error, 456)
      {:error, 456}

      iex> Result.Operators.from({:ok, 123}, "value")
      {:ok, 123}

      iex> Result.Operators.from({:error, "msg"}, "value")
      {:error, "msg"}
  """
  defmacro from(maybe, msg_or_val) do
    quote bind_quoted: [maybe: maybe, msg_or_val: msg_or_val] do
      case maybe do
        nil -> {:error, msg_or_val}
        :ok -> {:ok, msg_or_val}
        :error -> {:error, msg_or_val}
        {:ok, val} -> {:ok, val}
        {:error, msg} -> {:error, msg}
        val -> {:ok, val}
      end
    end
  end

  @doc """
  Apply a function `f` to `value` if result is Ok.

  ## Examples

      iex> ok = {:ok, 3}
      iex> Result.Operators.map(ok, fn(x) -> x + 10 end)
      {:ok, 13}

      iex> error = {:error, 3}
      iex> Result.Operators.map(error, fn(x) -> x + 10 end)
      {:error, 3}

  """
  defmacro map(result, f) do
    quote bind_quoted: [result: result, f: f] do
      with {:ok, val} <- result, do: {:ok, f.(val)}
    end
  end

  @doc """
  Apply a function if both results are Ok. If not, the first Err will propagate through.

  ## Examples

      iex> Result.Operators.map2({:ok, 1}, {:ok, 2}, fn(x, y) -> x + y end)
      {:ok, 3}

      iex> Result.Operators.map2({:ok, 1}, {:error, 2}, fn(x, y) -> x + y end)
      {:error, 2}

      iex> Result.Operators.map2({:error, 1}, {:error, 2}, fn(x, y) -> x + y end)
      {:error, 1}

  """
  defmacro map2(result1, result2, f) do
    quote bind_quoted: [result1: result1, result2: result2, f: f] do
      with {:ok, val1} <- result1, {:ok, val2} <- result2, do: {:ok, f.(val1, val2)}
    end
  end

  @doc """
  Apply a function `f` to `value` if result is Error.

  Transform an Error value. For example, say the errors we get have too much information

  ## Examples

      iex> error = {:error, %{msg: "ERROR", status: 4321}}
      iex> Result.Operators.map_error(error, &(&1.msg))
      {:error, "ERROR"}

      iex> ok = {:ok, 3}
      iex> Result.Operators.map_error(ok, fn(x) -> x + 10 end)
      {:ok, 3}

  """
  defmacro map_error(result, f) do
    quote bind_quoted: [result: result, f: f] do
      with {:error, val} <- result, do: {:error, f.(val)}
    end
  end

  @doc """
  Catch specific error `expected_error` and call function `f` with it.
  Others errors or oks pass untouched.

  ## Examples

      iex> error = {:error, :foo}
      iex> Result.Operators.catch_error(error, :foo, fn _ -> {:ok, "FOO"} end)
      {:ok, "FOO"}

      iex> error = {:error, :bar}
      iex> Result.Operators.catch_error(error, :foo, fn _ -> {:ok, "FOO"} end)
      {:error, :bar}

      iex> ok = {:ok, 3}
      iex> Result.Operators.catch_error(ok, :foo,  fn _ -> {:ok, "FOO"} end)
      {:ok, 3}

  """
  defmacro catch_error(result, expected_error, f) do
    quote bind_quoted: [result: result, expected_error: expected_error, f: f] do
      require Result.Utils
      err = expected_error
      with {:error, ^err} <- result, do: Result.Utils.check(f.(err))
    end
  end

  @doc """
  Catch all errors and call function `f` with it.
  #
  ## Examples

      iex> error = {:error, :foo}
      iex> Result.Operators.catch_all_errors(error, fn err -> {:ok, Atom.to_string(err)} end)
      {:ok, "foo"}

      iex> error = {:error, :bar}
      iex> Result.Operators.catch_all_errors(error, fn err -> {:ok, Atom.to_string(err)} end)
      {:ok, "bar"}

      iex> ok = {:ok, 3}
      iex> Result.Operators.catch_all_errors(ok, fn err -> {:ok, Atom.to_string(err)} end)
      {:ok, 3}
  """
  defmacro catch_all_errors(result, f) do
    quote bind_quoted: [result: result, f: f] do
      require Result.Utils
      with {:error, err} <- result, do: Result.Utils.check(f.(err))
    end
  end

  @doc """
  Perform function `f` on Ok result and return it

  ## Examples

      iex> Result.Operators.perform({:ok, 123}, fn(x) -> x * 100 end)
      {:ok, 123}

      iex> Result.Operators.perform({:error, 123}, fn(x) -> IO.puts(x) end)
      {:error, 123}

  """
  defmacro perform(result, f) do
    quote bind_quoted: [result: result, f: f] do
      with {:ok, val} <- result do
        f.(val)
        {:ok, val}
      end
    end
  end

  @doc """
  Return `value` if result is ok, otherwise `default`

  ## Examples

      iex> Result.Operators.with_default({:ok, 123}, 456)
      123

      iex> Result.Operators.with_default({:error, 123}, 456)
      456

  """
  defmacro with_default(result, default) do
    quote bind_quoted: [result: result, default: default] do
      case result do
        {:ok, value} -> value
        {:error, _} -> default
      end
    end
  end

  @doc """
  Return `true` if result is error

  ## Examples

      iex> Result.Operators.error?({:error, 123})
      true

      iex> Result.Operators.error?({:ok, 123})
      false

  """
  defmacro error?(result) do
    quote bind_quoted: [result: result] do
      match?({:error, _}, result)
    end
  end

  @doc """
  Return `true` if result is ok

  ## Examples

      iex> Result.Operators.ok?({:ok, 123})
      true

      iex> Result.Operators.ok?({:error, 123})
      false

  """
  defmacro ok?(result) do
    quote bind_quoted: [result: result] do
      match?({:ok, _}, result)
    end
  end

  @doc """
  Flatten nested results

  resolve :: Result x (Result x a) -> Result x a

  ## Examples

      iex> Result.Operators.resolve({:ok, {:ok, 1}})
      {:ok, 1}

      iex> Result.Operators.resolve({:ok, {:error, "one"}})
      {:error, "one"}

      iex> Result.Operators.resolve({:error, "two"})
      {:error, "two"}
  """
  defmacro resolve(result) do
    quote bind_quoted: [result: result] do
      case result do
        {:ok, {:ok, val}} -> {:ok, val}
        {:ok, {:error, err}} -> {:error, err}
        {:error, err} -> {:error, err}
      end
    end
  end

  @doc """
  Retry `count` times the function `f` if the result is negative

  retry :: Result err a -> (a -> Result err b) -> Int -> Int -> Result err b

  * `res` - input result
  * `f` - function retruns result
  * `count` - try count
  * `timeout` - timeout between retries

  ## Examples

      iex> Result.Operators.retry({:error, "Error"}, fn(x) -> {:ok, x} end, 3)
      {:error, "Error"}

      iex> Result.Operators.retry({:ok, "Ok"}, fn(x) -> {:ok, x} end, 3)
      {:ok, "Ok"}

      iex> Result.Operators.retry({:ok, "Ok"}, fn(_) -> {:error, "Error"} end, 3, 0)
      {:error, "Error"}
  """
  defmacro retry(res, f, count, timeout \\ 1000) do
    quote bind_quoted: [res: res, f: f, count: count, timeout: timeout] do
      with {:ok, first_arg} <- res do
        Enum.reduce_while(1..count//1, f.(first_arg), fn
          _, {:ok, val} ->
            {:halt, {:ok, val}}

          _, {:error, reason} ->
            Process.sleep(timeout)
            {:cont, f.(first_arg)}
        end)
      end
    end
  end
end
