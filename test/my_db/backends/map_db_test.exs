defmodule MyDb.Backends.MapDbTest do
  alias MyDb.Backends.MapDb, as: MapDb
  use ExUnit.Case, async: true
  doctest MapDb

  test "MapDb.new/0" do
    assert MapDb.new == %{}
  end

  test "MapDb.destroy/1" do
    db = MapDb.new
    assert MapDb.destroy(db) == :ok
  end

  test "MapDb.write/3" do
    db = MapDb.new
         |> MapDb.write(:foo, :bar)
         |> MapDb.write(:baz, 3)
    assert db == %{foo: :bar, baz: 3}
  end

  test "MapDb.delete/2" do
    db = %{baz: 3, foo: :bar} |> MapDb.delete(:foo)
    assert db == %{baz: 3}

    db = %{baz: 3, foo: :bar} |> MapDb.delete(:baz)
    assert db == %{foo: :bar}
  end

  test "MapDb.read/2" do
    db = %{baz: 3, foo: :bar}
    assert MapDb.read(db, :baz) == {:ok, 3}
    assert MapDb.read(db, :foo) == {:ok, :bar}
    assert MapDb.read(db, :bar) == {:error, :instance}
  end

  test "MapDb.match/2" do
    db = %{foo: 1, bar: 2, baz: 3, bim: 2}
    assert MapDb.match(db, 1) == [:foo]
    assert MapDb.match(db, 3) == [:baz]
    assert MapDb.match(db, 2) == [:bar, :bim]
  end
end
