defmodule MyDb.DbServer do
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

  @backends %{
    map_db: MyDb.Backends.MapDb,
    tree_db: MyDb.Backends.TreeDb,
    list_db: MyDb.Backends.ListDb,
    ets_db: MyDb.Backends.EtsDb,
    struct_db: MyDb.Backends.StructDb
  }

  def start do
    start(:map_db)
  end

  def start(backend_name) do
    {:ok, backend} = Map.fetch(@backends, backend_name)
    pid = spawn(MyDb.DbServer, :init, [backend])
    Process.register(pid, MyDb.DbServer)
    :ok
  end

  def stop() do
    send(MyDb.DbServer, {:destroy})
    :ok
  end

  def write(key, value) do
    call({:write, key, value})
  end

  def delete(key) do
    call({:delete, key})
  end

  def read(key) do
    call({:read, key})
  end

  def match(value) do
    call({:match, value})
  end

  def records() do
    call({:records})
  end

  def lock() do
    call({:lock})
  end

  def unlock() do
    call({:unlock})
  end

  defp call(message) do
    send(MyDb.DbServer, {:request, self(), message})

    receive do
      {:reply, reply} -> reply
    end
  end

  # not actually public
  def init(backend) do
    unlocked_loop(backend, backend.new)
  end

  defp unlocked_loop(backend, db) do
    receive do
      {:destroy} ->
        backend.destroy(db)
        :ok

      {:request, from, {:lock}} ->
        send(from, {:reply, :ok})
        locked_loop(backend, db, from)

      {:request, from, message} ->
        db = handle_request(backend, db, from, message)
        unlocked_loop(backend, db)
    end
  end

  defp locked_loop(backend, db, from) do
    receive do
      {:request, ^from, {:unlock}} ->
        send(from, {:reply, :ok})
        unlocked_loop(backend, db)

      {:request, ^from, message} ->
        db = handle_request(backend, db, from, message)
        locked_loop(backend, db, from)
    end
  end

  defp handle_request(backend, db, from, message) do
    case message do
      {:write, key, value} ->
        db = backend.write(db, key, value)
        send(from, {:reply, :ok})
        db

      {:read, key} ->
        result = backend.read(db, key)
        send(from, {:reply, result})
        db

      {:delete, key} ->
        db = backend.delete(db, key)
        send(from, {:reply, :ok})
        db

      {:match, value} ->
        results = backend.match(db, value)
        send(from, {:reply, results})
        db

      {:records} ->
        results = backend.records(db)
        send(from, {:reply, results})
        db
    end
  end
end
