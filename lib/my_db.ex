defmodule MyDb do
  @moduledoc """
  MyDb module (lib/my_db.ex) is intended to be an API module to a database. Imple-
  ment its functions by forwarding the calls to the DbServer module. The API should
  be as follows:

  MyDb.start() → :ok
  MyDb.stop() → :ok
  MyDb.write(key, element) → :ok
  MyDb.read(key) →{:ok, element} | {:error, :instance} MyDb.delete(key) → :ok
  MyDb.match(element) → {:ok, [key1, ..., keyn]}
  """

  alias MyDb.DbGenserver, as: Server

  @doc "Start the database server"
  def start(%{backend: backend}) do
    Server.start(backend)
  end

  def start do
    Server.start()
  end

  @doc "Stop the database server"
  def stop do
    Server.stop()
  end

  @doc "Write a key-value pair into the database"
  def write(key, value) do
    Server.write(key, value)
  end

  @doc "Delete a key-value pair from the database (given the key)"
  def delete(key) do
    Server.delete(key)
  end

  @doc "Read the value from the database for a given key"
  def read(key) do
    Server.read(key)
  end

  @doc "Find all keys that have a specified value in the database"
  def match(value) do
    Server.match(value)
  end
end
