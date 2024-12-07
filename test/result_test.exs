defmodule ResultTest do
  use ExUnit.Case
  require Result.Ok
  require Result.Error
  doctest Result.Ok
  doctest Result.Error
end
