defmodule Db do
  @moduledoc """
  Implement an in-memory database system.

  Records are stored as key-value tuples, prepended onto the array, and
  looked up by searching the array linearly.
  """

  @doc "create a new 'database'"
  def new do [] end

  @doc "clean up an existing database"
  def destroy(_db) do :ok end

  @doc "write a new record onto the database"
  def write(db, key, value) do [{key, value} | db] end

  @doc "delete a record from the database"
  def delete(db, key) do filter(db, fn {k, _v} -> k != key end) end

  @doc "read the value for a record from the database"
  def read(db, key) do
    case find_records_by_key(db, key) do
      [] -> {:error, :instance}
      [{_k, v} | _rest] -> {:ok, v}
    end
  end

  @doc "find all of the keys that match a given value"
  def match(db, value) do
    find_records_by_value(db, value)
    |> map(fn {k, _v} -> k end)
  end

  defp find_records_by_key(db, key) do filter(db, fn {k, _v} -> k == key end) end
  defp find_records_by_value(db, value) do filter(db, fn {_k, v} -> v == value end) end


  ## Because I'm not supposed to use Enum, I reimplemented the bits of it I needed below.

  defp reverse(list) do reverse([], list) end
  defp reverse(output, []) do output end
  defp reverse(output, [head | rest]) do reverse([head | output], rest) end

  defp filter(list, function) do reverse(filter([], list, function)) end
  defp filter(output, [], _function) do output end
  defp filter(output, [record | remaining], function) do
    if function.(record) do
      filter([record | output], remaining, function)
    else
      filter(output, remaining, function)
    end
  end

  defp map(list, function) do reverse(map([], list, function)) end
  defp map(output, [], _function) do output end
  defp map(output, [head | rest], function) do map([function.(head) | output], rest, function) end
end
