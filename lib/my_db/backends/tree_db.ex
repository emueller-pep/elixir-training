defmodule MyDb.Backends.TreeDb do
  @moduledoc """
  Implement an in-memory database system.

  Records are stored in a sorted binary tree, holding tuples like {key, value, left, right},
  and using the sentinel atom :empty for leaves that don't exist.
  """

  @doc "create a new database"
  def new do :empty end

  @doc "initialize a TreeDb with some records (in tuple-list format)"
  def new(records) do from_records(new(), records) end

  defp from_records(db, []) do db end
  defp from_records(db, [{ key, value } | rest]) do
    from_records(write(db, key, value), rest)
  end

  @doc "clean up an existing database"
  def destroy(_db) do :ok end

  @doc "write a new record onto the database"
  def write(:empty, key, value) do { key, value, :empty, :empty } end
  def write({ k, v, left, right }, key, value) do
    if key < k do
      { k, v, write(left, key, value), right }
    else
      { k, v, left, write(right, key, value) }
    end
  end

  @doc "delete a record out of the database"
  def delete(:empty, _key) do :empty end
  def delete({ k, v, left, right }, key) do
    cond do
      (k > key) -> { k, v, delete(left, key), right }
      (k < key) -> { k, v, left, delete(right, key) }
      (k == key) -> delete_node({ k, v, delete(left, key), delete(right, key) })
    end
  end

  defp delete_node(:empty) do :empty end
  defp delete_node({ _k, _v, :empty, :empty }) do :empty end
  defp delete_node({ _k, _v, :empty, right }) do right end
  defp delete_node({ _k, _v, left, :empty }) do left end
  defp delete_node({ _k, _v, { lk, lv, ll, lr }, right }) do
    { lk, lv, delete_node({ lk, lv, ll, lr }), right }
  end

  @doc "read a single value out of the tree-db"
  def read(:empty, _key) do { :error, :instance } end
  def read({ k, v, left, right }, key) do 
    cond do
      (key == k) -> { :ok, v }
      (key < k) -> read(left, key)
      (key > k) -> read(right, key)
    end
  end

  @doc "find the keys of all of the records matching a given value"
  def match(db, value) do
    records(db)
    |> Manipulate.filter(fn({ _k, v }) -> v == value end)
    |> Manipulate.map(fn({ k, _v }) -> k end)
  end

  @doc "print all records"
  def print_all(:empty) do end
  def print_all({ k, v, left, right }) do
    if left != :empty do
      print_all(left)
    end

    IO.puts "#{k} => #{v}"

    if right != :empty do
      print_all(right)
    end
  end

  @doc "return all records as a list of key-value tuples"
  def records(:empty) do [] end
  def records({ k, v, left, right }) do
    Manipulate.concatenate([records(left), [{ k, v }], records(right)])
  end
end

