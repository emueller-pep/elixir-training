defmodule MyDb.Backends.MapDb do
  @moduledoc """
  Take the db.ex module you wrote in exercise 2.4. Rewrite it using maps. Test it using your
  database server you wrote in exercise 4.1.

  Note: Make sure you save a copy of your db.ex module using lists somewhere else (or with a
  new name) before you start changing in.
  """

  @doc "create a new database"
  def new do %{} end

  @doc "clean up an existing database"
  def destroy(_db) do :ok end

  @doc "write a new record onto the database"
  def write(db, key, value) do Map.put(db, key, value) end

  @doc "delete a record from the database"
  def delete(db, key) do Map.delete(db, key) end

  @doc "read the value for a record from the database"
  def read(db, key) do
    case db do
      %{^key => value} -> { :ok, value }
      _ -> { :error, :instance }
    end
  end

  @doc "find all keys having the supplied value in the database"
  def match(db, value) do
    Enum.filter(db, fn({_k,v}) -> v == value end)
    |> Enum.map(fn({k,_v}) -> k end)
  end
end
