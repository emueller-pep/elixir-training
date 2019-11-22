defmodule MyDbTest do
  use ExUnit.Case, async: false
  doctest MyDb

  setup do
    :ok = MyDb.start()
    :ok = MyDb.write(:a, 1)
    :ok = MyDb.write(:b, 2)
    :ok = MyDb.write(:c, 3)
    :ok = MyDb.write(:d, 2)
  end

  test "read/1, write/2" do
    assert MyDb.read(:x) == {:error, :instance}
    assert MyDb.write(:x, 77) == :ok
    assert MyDb.read(:x) == {:ok, 77}
  end

  test "delete/1" do
    # key exists
    assert MyDb.delete(:a) == :ok
    assert MyDb.read(:a) == {:error, :instance}

    # key does not exist
    assert MyDb.delete(:a) == :ok
  end

  test "match/1" do
    # no matches
    assert MyDb.match(404) == {:ok, []}

    # one match
    assert MyDb.match(1) == {:ok, [:a]}

    # multiple matches
    {:ok, matches} = MyDb.match(2)
    assert Enum.sort(matches) == [:b, :d]
  end
end
