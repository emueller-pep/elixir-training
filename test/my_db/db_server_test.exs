defmodule MyDb.DbServerTest do
  alias MyDb.DbServer.Client, as: Client
  use ExUnit.Case, async: false
  doctest MyDb.DbServer

  test "write/2" do
    :ok = Client.start()
    assert Client.read(:foo) == {:error, :instance}
    assert Client.write(:foo, 5)
    assert Client.read(:foo) == {:ok, 5}
    :ok = Client.stop()
  end

  test "delete/1" do
    :ok = Client.start()
    Client.write(:foo, 5)
    Client.write(:bar, 6)

    assert Client.delete(:foo) == :ok
    assert Client.read(:foo) == {:error, :instance}
    assert Client.read(:bar) == {:ok, 6}
    :ok = Client.stop()
  end

  test "read/1" do
    :ok = Client.start()
    Client.write(:foo, 5)
    Client.write(:bar, 6)

    assert Client.read(:foo) == {:ok, 5}
    assert Client.read(:baz) == {:error, :instance}
    :ok = Client.stop()
  end

  test "match/1" do
    :ok = Client.start()
    Client.write(:foo, 5)
    Client.write(:bar, 6)
    Client.write(:bam, 5)

    {:ok, matches} = Client.match(5)
    assert Enum.sort(matches) == [:bam, :foo]
    assert Client.match(6) == {:ok, [:bar]}
    :ok = Client.stop()
  end

  describe "through the backends" do
    test ":list_db" do
      :ok = Client.start(MyDb.Backends.ListDb)
      assert Client.write(:a, 1) == :ok
      assert Client.write(:b, 2) == :ok
      assert Client.write(:c, 1) == :ok

      assert Client.read(:a) == {:ok, 1}
      assert Client.read(:z) == {:error, :instance}

      {:ok, matches} = Client.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Client.delete(:a) == :ok
      assert Client.read(:a) == {:error, :instance}

      assert Client.stop() == :ok
    end

    test ":map_db" do
      :ok = Client.start(MyDb.Backends.MapDb)
      assert Client.write(:a, 1) == :ok
      assert Client.write(:b, 2) == :ok
      assert Client.write(:c, 1) == :ok

      assert Client.read(:a) == {:ok, 1}
      assert Client.read(:z) == {:error, :instance}

      {:ok, matches} = Client.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Client.delete(:a) == :ok
      assert Client.read(:a) == {:error, :instance}

      assert Client.stop() == :ok
    end

    test ":tree_db" do
      :ok = Client.start(MyDb.Backends.TreeDb)
      assert Client.write(:a, 1) == :ok
      assert Client.write(:b, 2) == :ok
      assert Client.write(:c, 1) == :ok

      assert Client.read(:a) == {:ok, 1}
      assert Client.read(:z) == {:error, :instance}

      {:ok, matches} = Client.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Client.delete(:a) == :ok
      assert Client.read(:a) == {:error, :instance}

      assert Client.stop() == :ok
    end

    test ":struct_db" do
      :ok = Client.start(MyDb.Backends.StructDb)
      assert Client.write(:a, 1) == :ok
      assert Client.write(:b, 2) == :ok
      assert Client.write(:c, 1) == :ok

      assert Client.read(:a) == {:ok, 1}
      assert Client.read(:z) == {:error, :instance}

      {:ok, matches} = Client.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Client.delete(:a) == :ok
      assert Client.read(:a) == {:error, :instance}

      assert Client.stop() == :ok
    end

    test ":ets_db" do
      :ok = Client.start(MyDb.Backends.EtsDb)
      assert Client.write(:a, 1) == :ok
      assert Client.write(:b, 2) == :ok
      assert Client.write(:c, 1) == :ok

      assert Client.read(:a) == {:ok, 1}
      assert Client.read(:z) == {:error, :instance}

      {:ok, matches} = Client.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Client.delete(:a) == :ok
      assert Client.read(:a) == {:error, :instance}

      assert Client.stop() == :ok
    end
  end
end
