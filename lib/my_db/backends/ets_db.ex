defmodule MyDb.Backends.EtsDb do
  @moduledoc """
  Implement an ETS backed database system
  """

  defmodule Table do
    defstruct [:table_id, :name]
  end

  @doc "create a new database"
  def new do
    table_id = :ets.new(MyDb.Backends.EtsDb, [:ordered_set, :private])
    %Table{table_id: table_id, name: MyDb.Backends.EtsDb}
  end

  @doc "create a new database and initialize it with data"
  def new(pairs) do
    Enum.reduce(pairs, new(), fn {k, v}, db -> write(db, k, v) end)
  end

  @doc "clean up an existing database"
  def destroy(db) do
    :ets.delete(db.table_id)
    :ok
  end

  defp encode(x) do
    :erlang.term_to_binary(x)
  end

  defp decode(x) do
    :erlang.binary_to_term(x)
  end

  @doc "write a key and value into the database"
  def write(db, key, value) do
    :ets.insert(db.table_id, {encode(key), encode(value)})
    db
  end

  @doc "read a key and value from the database"
  def read(db, key) do
    results = :ets.lookup(db.table_id, encode(key))

    case results do
      [] -> {:error, :instance}
      [{_bkey, bvalue} | _rest] -> {:ok, decode(bvalue)}
    end
  end

  @doc "delete a key from the database"
  def delete(db, key) do
    :ets.delete(db.table_id, encode(key))
    db
  end

  @doc "find all keys matching the given value"
  def match(db, value) do
    results =
      :ets.match(db.table_id, {:"$1", encode(value)})
      |> Enum.map(fn [bk] -> decode(bk) end)

    {:ok, results}
  end

  @doc "dump every record as a kv-tuple"
  def records(db) do
    :ets.match(db.table_id, {:"$1", :"$2"})
    |> Enum.map(fn [bk, bv] -> {decode(bk), decode(bv)} end)
  end
end
