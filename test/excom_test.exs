defmodule ExcomTest do
  use ExUnit.Case
  doctest Excom

  test "greets the world" do
    assert Excom.hello() == :world
  end
end
