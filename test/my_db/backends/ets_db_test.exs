defmodule MyDb.Backends.EtsDbTest do
  alias MyDb.Backends.EtsDb, as: EtsDb
  use ExUnit.Case, async: true
  doctest EtsDb

  test "new/0" do
    db = EtsDb.new()
    assert db.name == EtsDb
    assert db.table_id != nil
  end

  test "new/1" do
    db = EtsDb.new(a: 1, b: 2, c: 3, d: 1)
    assert EtsDb.read(db, :c) == {:ok, 3}
  end

  test "destroy/1" do
    db = EtsDb.new()
    assert EtsDb.destroy(db) == :ok
    catch_error(EtsDb.read(db, :a))
  end

  test "write/3" do
    db = EtsDb.new()
    assert EtsDb.read(db, :a) == {:error, :instance}

    db = EtsDb.write(db, :a, 3)
    assert EtsDb.read(db, :a) == {:ok, 3}
  end

  test "read/2" do
    db = EtsDb.new(a: 1, b: 2, c: 3, d: 1)
    assert EtsDb.read(db, :a) == {:ok, 1}
    assert EtsDb.read(db, "a") == {:error, :instance}
    assert EtsDb.read(db, :e) == {:error, :instance}
  end

  test "match/2" do
    db = EtsDb.new(a: 1, b: 2, c: 3, d: 1)

    assert EtsDb.match(db, 3) == {:ok, [:c]}

    {:ok, matches} = EtsDb.match(db, 1)
    assert Enum.sort(matches) == [:a, :d]

    # Check the $1 case specially
    db = EtsDb.new([{"a", :"$1"}, {"b", :"$2"}])
    assert EtsDb.match(db, :"$1") == {:ok, ["a"]}
  end

  test "records/1" do
    db = EtsDb.new(a: 1, b: 2, c: 1)
    assert EtsDb.records(db) == [a: 1, b: 2, c: 1]
  end
end
