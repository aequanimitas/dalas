defmodule DalasTest do
  use ExUnit.Case
  doctest Dalas

  defp assert_down(name) do
    Dalas.stop(name)
    assert :ok = Dalas.stop(name)
  end

  test "starting" do
    assert :error = Dalas.start(1)
  end
end
