defmodule MyDb.DbGenserverTest do
  alias MyDb.DbGenserver, as: Server
  alias MyDb.Backends.MapDb, as: MapDb
  use ExUnit.Case, async: false

  describe "client API" do
    setup do: Server.start(MapDb) 

    test "write/2" do
      { :error, :instance } = Server.read(:a)
      assert Server.write(:a, 1) == :ok
      assert Server.read(:a) == { :ok, 1 }
    end

    test "write_async/2" do
      { :error, :instance } = Server.read(:a)
      assert Server.write(:a, 1) == :ok
      assert Server.read(:a) == { :ok, 1 }
    end

    test "delete/1" do
      :ok = Server.write(:a, 1)
      { :ok, 1 } = Server.read(:a)
      assert Server.delete(:a) == :ok
      assert Server.read(:a) == { :error, :instance }
    end

    test "delete_async/1" do
      :ok = Server.write(:a, 1)
      { :ok, 1 } = Server.read(:a)
      assert Server.delete_async(:a) == :ok
      assert Server.read(:a) == { :error, :instance }
    end

    test "read/1" do
      assert Server.read(:fooba) == { :error, :instance }

      :ok = Server.write(:a, 1)
      assert Server.read(:a) == { :ok, 1 }
    end

    test "match/1" do
      :ok = Server.write(:a, 1)
      :ok = Server.write(:b, 2)
      :ok = Server.write(:c, 1)

      { :ok, matches } = Server.match(1)
      assert Enum.sort(matches) == [:a, :c]
    end
  end
end
