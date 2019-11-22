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

  describe "lock/0" do
    setup do: Client.start(MapDb)

    test "lock when not locked yet" do
      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == nil
      assert Client.lock == :ok
      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == self()
    end

    test "lock when already locked by me" do
      # fake myself having already locked it
      assert GenServer.call(MyDb.DbGenserver, {:lock, self()})

      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == self() 
      assert Client.lock == :ok
      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == self()
    end

    test "lock when already locked by someone else" do
      # fake someone else having already locked it
      GenServer.call(MyDb.DbGenserver, {:lock, :someone_else})

      assert Client.lock == :error
      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == :someone_else
    end
  end

  describe "unlock/0" do
    setup do: Client.start(MapDb)

    test "when not locked" do
      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == nil
      assert Client.unlock == :ok
      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == nil
    end

    test "when locked by me" do
      Client.lock

      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == self()
      assert Client.unlock == :ok
      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == nil
    end

    test "when locked by someone else" do
      # fake someone else having already locked it
      GenServer.call(MyDb.DbGenserver, {:lock, :someone_else})

      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == :someone_else
      assert Client.unlock == :error
      assert :sys.get_state(MyDb.DbGenserver)[:locked_by] == :someone_else
    end
  end
end
