defmodule NetdbTest do
  use ExUnit.Case
  doctest Netdb

  test "greets the world" do
    assert Netdb.hello() == :world
  end
end
