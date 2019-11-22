defmodule MyDb.DbGenserverTest do
  alias MyDb.DbGenserver.Client, as: Client
  alias MyDb.Backends.MapDb, as: MapDb
  use ExUnit.Case, async: false

  describe "MyDb.DbGenserver.Client" do
    setup do: Client.start(MapDb)

    test "write/2" do
      {:error, :instance} = Client.read(:a)
      assert Client.write(:a, 1) == :ok
      assert Client.read(:a) == {:ok, 1}
    end

    test "write_async/2" do
      {:error, :instance} = Client.read(:a)
      assert Client.write(:a, 1) == :ok
      assert Client.read(:a) == {:ok, 1}
    end

    test "delete/1" do
      :ok = Client.write(:a, 1)
      {:ok, 1} = Client.read(:a)
      assert Client.delete(:a) == :ok
      assert Client.read(:a) == {:error, :instance}
    end

    test "delete_async/1" do
      :ok = Client.write(:a, 1)
      {:ok, 1} = Client.read(:a)
      assert Client.delete_async(:a) == :ok
      assert Client.read(:a) == {:error, :instance}
    end

    test "read/1" do
      assert Client.read(:fooba) == {:error, :instance}

      :ok = Client.write(:a, 1)
      assert Client.read(:a) == {:ok, 1}
    end

    test "match/1" do
      :ok = Client.write(:a, 1)
      :ok = Client.write(:b, 2)
      :ok = Client.write(:c, 1)

      {:ok, matches} = Client.match(1)
      assert Enum.sort(matches) == [:a, :c]
    end
  end
end
