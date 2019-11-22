defmodule MyDb.Backends.ListDbTest do
  alias MyDb.Backends.ListDb, as: ListDb
  use ExUnit.Case, async: true
  doctest ListDb

  test "new/0" do
    assert ListDb.new() == []
  end

  test "destroy/1" do
    db = ListDb.new()
    assert ListDb.destroy(db) == :ok
  end

  test "write/3" do
    db =
      ListDb.new()
      |> ListDb.write(:foo, :bar)
      |> ListDb.write(:baz, 3)

    assert db == [baz: 3, foo: :bar]
  end

  test "delete/2" do
    db = [baz: 3, foo: :bar] |> ListDb.delete(:foo)
    assert db == [baz: 3]

    db = [baz: 3, foo: :bar] |> ListDb.delete(:baz)
    assert db == [foo: :bar]
  end

  test "read/2" do
    db = [baz: 3, foo: :bar]
    assert ListDb.read(db, :baz) == {:ok, 3}
    assert ListDb.read(db, :foo) == {:ok, :bar}
    assert ListDb.read(db, :bar) == {:error, :instance}
  end

  test "match/2" do
    db = [foo: 1, bar: 2, baz: 3, bar: 7, bim: 2]
    assert ListDb.match(db, 1) == {:ok, [:foo]}
    assert ListDb.match(db, 3) == {:ok, [:baz]}
    assert ListDb.match(db, 2) == {:ok, [:bar, :bim]}
  end
end
