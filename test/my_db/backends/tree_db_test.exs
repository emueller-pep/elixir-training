defmodule TreeDbTest do
  use ExUnit.Case, async: true
  doctest TreeDb

  test "TreeDb.new/0" do
    assert TreeDb.new == :empty
  end

  test "TreeDb.new/1" do
    assert TreeDb.new([]) == TreeDb.new
    assert TreeDb.new([a: 1]) == { :a, 1, :empty, :empty }
    assert TreeDb.new([a: 1, c: 2, b: 3]) == TreeDb.new |> TreeDb.write(:a, 1) |> TreeDb.write(:c, 2) |> TreeDb.write(:b, 3)
  end

  test "TreeDb.records/1" do
    assert TreeDb.records(:empty) == []
    assert TreeDb.records({ :a, :b, :empty, :empty }) == [{:a, :b}]
    assert TreeDb.records({ :a, :b, { :c, 1, :empty, :empty }, { :d, 2, :empty, :empty}}) == [c: 1, a: :b, d: 2]
  end

  test "TreeDb.destroy/1" do
    db = TreeDb.new
    assert TreeDb.destroy(db) == :ok
  end

  test "TreeDb.write/3" do
    db = TreeDb.new
         |> TreeDb.write(:foo, :bar)
         |> TreeDb.write(:baz, 3)
    assert TreeDb.records(db) == [baz: 3, foo: :bar]
  end

  test "TreeDb.delete/2" do
    db = TreeDb.new([baz: 3, foo: :bar]) |> TreeDb.delete(:foo)
    assert TreeDb.records(db) == [baz: 3]

    db = TreeDb.new([baz: 3, foo: :bar]) |> TreeDb.delete(:baz)
    assert TreeDb.records(db) == [foo: :bar]

    db = TreeDb.new([a: 1, c: 3, b: 2, d: 4, e: 77]) |> TreeDb.delete(:c)
    assert TreeDb.records(db) == [a: 1, b: 2, d: 4, e: 77]

    db = TreeDb.new([a: 1, a: 2, b: 3, a: 4]) |> TreeDb.delete(:a)
    assert TreeDb.records(db) == [b: 3]
  end

  test "TreeDb.read/2" do
    db = TreeDb.new |> TreeDb.write(:foo, :bar) |> TreeDb.write(:baz, 3)
    assert TreeDb.read(db, :baz) == {:ok, 3}
    assert TreeDb.read(db, :foo) == {:ok, :bar}
    assert TreeDb.read(db, :bar) == {:error, :instance}
  end

  test "TreeDb.match/2" do
    db = TreeDb.new([foo: 1, bar: 2, baz: 3, bar: 7, bim: 2])
    assert TreeDb.match(db, 1) == [:foo]
    assert TreeDb.match(db, 3) == [:baz]
    assert TreeDb.match(db, 2) == [:bar, :bim]
  end
end
