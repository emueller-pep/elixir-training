ExUnit.start()

defmodule DbTest do
  use ExUnit.Case, async: true

  test "Db.new/0" do
    assert Db.new == []
  end

  test "Db.destroy/1" do
    db = Db.new
    assert Db.destroy(db) == :ok
  end

  test "Db.write/3" do
    db = Db.new
         |> Db.write(:foo, :bar)
         |> Db.write(:baz, 3)
    assert db == [baz: 3, foo: :bar]
  end

  test "Db.delete/2" do
    db = [baz: 3, foo: :bar] |> Db.delete(:foo)
    assert db == [baz: 3]

    db = [baz: 3, foo: :bar] |> Db.delete(:baz)
    assert db == [foo: :bar]
  end

  test "Db.read/2" do
    db = [baz: 3, foo: :bar]
    assert Db.read(db, :baz) == {:ok, 3}
    assert Db.read(db, :foo) == {:ok, :bar}
    assert Db.read(db, :bar) == {:error, :instance}
  end

  test "Db.match/2" do
    db = [foo: 1, bar: 2, baz: 3, bar: 7, bim: 2]
    assert Db.match(db, 1) == [:foo]
    assert Db.match(db, 3) == [:baz]
    assert Db.match(db, 2) == [:bar, :bim]
  end
end
