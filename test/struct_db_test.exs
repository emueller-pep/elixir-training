defmodule StructDbTest do
  use ExUnit.Case, async: true
  doctest StructDb

  test "StructDb.new/0" do
    assert StructDb.new == []
  end

  test "StructDb.new/1" do
    assert StructDb.new([]) == []
    assert StructDb.new([foo: :bar]) == [%StructDb.Record{key: :foo, value: :bar}]
    assert length(StructDb.new([foo: :bar, a: 1, b: 2])) == 3
  end

  test "StructDb.destroy/1" do
    db = StructDb.new([foo: :bar])
    assert StructDb.destroy(db) == :ok
  end

  test "StructDb.write/3" do
    db = StructDb.new([foo: :bar, baz: 3])
    assert length(db) == 2
    assert Enum.member?(db, %StructDb.Record{key: :foo, value: :bar})
    assert Enum.member?(db, %StructDb.Record{key: :baz, value: 3})
  end

  test "StructDb.delete/2" do
    initialdb = StructDb.new([baz: 3, foo: :bar])
    assert StructDb.delete(initialdb, :foo) == [%StructDb.Record{key: :baz, value: 3}]
    assert StructDb.delete(initialdb, :baz) == [%StructDb.Record{key: :foo, value: :bar}]
  end

  test "StructDb.read/2" do
    db = StructDb.new([baz: 3, foo: :bar])
    assert StructDb.read(db, :baz) == {:ok, 3}
    assert StructDb.read(db, :foo) == {:ok, :bar}
    assert StructDb.read(db, :bar) == {:error, :instance}
  end

  test "StructDb.match/2" do
    db = StructDb.new([foo: 1, bar: 2, baz: 3, bim: 2])
    assert StructDb.match(db, 1) == [:foo]
    assert StructDb.match(db, 3) == [:baz]
    assert Enum.sort(StructDb.match(db, 2)) == [:bar, :bim]
  end
end
