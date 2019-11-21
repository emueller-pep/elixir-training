defmodule MyDb.Backends.StructDb do
  @moduledoc """
  Take the db.ex module you wrote in exercise 2.4. Rewrite it using maps. Test it using your
  database server you wrote in exercise 4.1.

  Note: Make sure you save a copy of your db.ex module using lists somewhere else (or with a
  new name) before you start changing in.
  """

  defmodule Record do
    defstruct [:key, :value]
  end

  @doc "create a new database"
  def new do [] end
  def new([]) do new() end
  def new(pairs) do Enum.reduce([new() | pairs], fn({k,v}, db) -> [%Record{key: k, value: v} | db] end) end

  @doc "clean up an existing database"
  def destroy(_db) do :ok end

  @doc "write a new record onto the database"
  def write(db, key, value) do [%Record{key: key, value: value} | db] end

  @doc "delete a record from the database"
  def delete(db, key) do Enum.filter(db, fn %Record{key: k} -> k != key end) end

  @doc "read the value for a record from the database"
  def read(db, key) do
    match = Enum.find(db, fn %Record{key: k} -> k == key end)
    if match == nil do
      { :error, :instance }
    else
      { :ok, match.value }
    end
  end

  @doc "find all keys having the supplied value in the database"
  def match(db, value) do
    Enum.filter(db, fn %Record{value: v} -> v == value end)
    |> Enum.map(fn record -> record.key end)
  end
end
