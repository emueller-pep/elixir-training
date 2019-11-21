defmodule MyDb.DbServerTest do
  alias MyDb.DbServer, as: Server
  use ExUnit.Case, async: false
  doctest MyDb.DbServer

  test "write/2" do
    :ok = Server.start
    assert Server.read(:foo) == { :error, :instance }
    assert Server.write(:foo, 5)
    assert Server.read(:foo) == { :ok, 5 }
    :ok = Server.stop
  end

  test "delete/1" do
    :ok = Server.start
    Server.write(:foo, 5)
    Server.write(:bar, 6)

    assert Server.delete(:foo) == :ok
    assert Server.read(:foo) == { :error, :instance }
    assert Server.read(:bar) == { :ok, 6 }
    :ok = Server.stop
  end

  test "read/1" do
    :ok = Server.start
    Server.write(:foo, 5)
    Server.write(:bar, 6)

    assert Server.read(:foo) == { :ok, 5 }
    assert Server.read(:baz) == { :error, :instance }
    :ok = Server.stop
  end

  test "match/1" do
    :ok = Server.start
    Server.write(:foo, 5)
    Server.write(:bar, 6)
    Server.write(:bam, 5)

    { :ok, matches } = Server.match(5)
    assert Enum.sort(matches) == [:bam, :foo]
    assert Server.match(6) == { :ok, [:bar] }
    :ok = Server.stop
  end

  describe "through the backends" do
    test ":list_db" do
      :ok = Server.start(:list_db)
      assert Server.write(:a, 1) == :ok
      assert Server.write(:b, 2) == :ok
      assert Server.write(:c, 1) == :ok

      assert Server.read(:a) == { :ok, 1 }
      assert Server.read(:z) == { :error, :instance }

      { :ok, matches } = Server.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Server.delete(:a) == :ok
      assert Server.read(:a) == { :error, :instance }

      assert Server.stop == :ok
    end

    test ":map_db" do
      :ok = Server.start(:map_db)
      assert Server.write(:a, 1) == :ok
      assert Server.write(:b, 2) == :ok
      assert Server.write(:c, 1) == :ok

      assert Server.read(:a) == { :ok, 1 }
      assert Server.read(:z) == { :error, :instance }

      { :ok, matches } = Server.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Server.delete(:a) == :ok
      assert Server.read(:a) == { :error, :instance }

      assert Server.stop == :ok
    end

    test ":tree_db" do
      :ok = Server.start(:tree_db)
      assert Server.write(:a, 1) == :ok
      assert Server.write(:b, 2) == :ok
      assert Server.write(:c, 1) == :ok

      assert Server.read(:a) == { :ok, 1 }
      assert Server.read(:z) == { :error, :instance }

      { :ok, matches } = Server.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Server.delete(:a) == :ok
      assert Server.read(:a) == { :error, :instance }

      assert Server.stop == :ok
    end

    test ":struct_db" do
      :ok = Server.start(:struct_db)
      assert Server.write(:a, 1) == :ok
      assert Server.write(:b, 2) == :ok
      assert Server.write(:c, 1) == :ok

      assert Server.read(:a) == { :ok, 1 }
      assert Server.read(:z) == { :error, :instance }

      { :ok, matches } = Server.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Server.delete(:a) == :ok
      assert Server.read(:a) == { :error, :instance }

      assert Server.stop == :ok
    end

    test ":ets_db" do
      :ok = Server.start(:ets_db)
      assert Server.write(:a, 1) == :ok
      assert Server.write(:b, 2) == :ok
      assert Server.write(:c, 1) == :ok

      assert Server.read(:a) == { :ok, 1 }
      assert Server.read(:z) == { :error, :instance }

      { :ok, matches } = Server.match(1)
      assert Enum.sort(matches) == [:a, :c]

      assert Server.delete(:a) == :ok
      assert Server.read(:a) == { :error, :instance }

      assert Server.stop == :ok
    end
  end
end
