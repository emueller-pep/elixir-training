defmodule MyDb do
  @moduledoc """
  Write a database server that stores a database in its loop data. You should register the server
  and access its services through a functional interface. Exported functions in the MyDb module
  should include:

  MyDb.start() → :ok
  MyDb.stop() → :ok
  MyDb.write(key, element) → :ok
  MyDb.delete(key) → :ok
  MyDb.read(key) → {:ok, element} | {:error, :instance}
  MyDb.match(element) → [key1, ..., keyn]
  """

  def start() do
    pid = spawn(MyDb, :init, [])
    Process.register(pid, MyDb)
    :ok
  end

  def stop() do
    send(MyDb, { :destroy })
  end

  def write(key, value) do call({ :write, key, value }) end
  def delete(key) do call({ :delete, key }) end
  def read(key) do call({ :read, key }) end
  def match(value) do call({ :match, value }) end
  def records() do call({ :records }) end
  def lock() do call({ :lock }) end
  def unlock() do call({ :unlock }) end

  defp call(message) do
    send(MyDb, { :request, self(), message })
    receive do
      { :reply, reply } -> reply
    end
  end

  # not actually public
  def init() do unlocked_loop(TreeDb.new) end

  defp unlocked_loop(db) do
    receive do
      { :destroy } -> TreeDb.destroy(db); :ok
      { :request, from, { :lock } } -> 
        send(from, { :reply, :ok })
        locked_loop(db, from)
      { :request, from, message } ->
        unlocked_loop(handle_request(db, from, message))
    end
  end

  defp locked_loop(db, from) do
    receive do
      { :request, ^from, { :unlock } } ->
        send(from, { :reply, :ok })
        unlocked_loop(db)
      { :request, ^from, message } ->
        locked_loop(handle_request(db, from, message), from)
    end
  end

  defp handle_request(db, from, message) do
    case message do
      { :write, key, value } ->
        db = TreeDb.write(db, key, value)
        send(from, { :reply, :ok })
        db
      { :read, key } ->
        result = TreeDb.read(db, key)
        send(from, { :reply, result })
        db
      { :delete, key } ->
        db = TreeDb.delete(db, key)
        send(from, { :reply, :ok })
        db
      { :match, value } ->
        results = TreeDb.match(db, value)
        send(from, { :reply, results })
        db
      { :records } ->
        results = TreeDb.records(db)
        send(from, { :reply, results })
        db
    end
  end
end
