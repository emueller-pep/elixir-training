defmodule MyDb.DbGenserver do
  use GenServer

  @moduledoc """
  implement a database server using Genserver
  """

  defmodule Client do
    @moduledoc "The methods used by the client to communicate with the server"

    def start do
      start(MyDb.Backends.MapDb)
    end

    def start(backend) do
      {:ok, _pid} = GenServer.start_link(MyDb.DbGenserver, backend, name: MyDb.DbGenserver)
      :ok
    end

    def stop do
      pid = Process.whereis(MyDb.DbGenserver)
      IO.puts("trying to stop #{inspect({MyDb.DbGenserver, :normal, 1_000})} (#{inspect(pid)})")
      :ok = GenServer.stop(MyDb.DbGenserver, :normal, 1_000)
      :ok
    end

    def write(key, value) do
      GenServer.call(MyDb.DbGenserver, {:write, key, value})
    end

    def delete(key) do
      GenServer.call(MyDb.DbGenserver, {:delete, key})
    end

    def read(key) do
      GenServer.call(MyDb.DbGenserver, {:read, key})
    end

    def match(value) do
      GenServer.call(MyDb.DbGenserver, {:match, value})
    end

    def write_async(key, value) do
      GenServer.cast(MyDb.DbGenserver, {:write, key, value})
      :ok
    end

    def delete_async(key) do
      GenServer.cast(MyDb.DbGenserver, {:delete, key})
      :ok
    end
  end

  ## GenServer callbacks ------------------------------------------------------

  @impl true
  def init(backend) do
    {:ok, %{db: backend.new, backend: backend}}
  end

  @impl true
  def terminate(_reason, %{db: db, backend: backend}) do
    backend.destroy(db)
  end

  ## Message handlers

  @impl true
  def handle_cast({:write, key, value}, state) do
    %{db: db, backend: backend} = state
    newdb = backend.write(db, key, value)
    {:noreply, %{state | db: newdb}}
  end

  @impl true
  def handle_cast({:delete, key}, state) do
    %{db: db, backend: backend} = state
    newdb = backend.delete(db, key)
    {:noreply, %{state | db: newdb}}
  end

  @impl true
  def handle_call({:write, key, value}, _from, state) do
    %{db: db, backend: backend} = state
    newdb = backend.write(db, key, value)
    {:reply, :ok, %{state | db: newdb}}
  end

  @impl true
  def handle_call({:delete, key}, _from, state) do
    %{db: db, backend: backend} = state
    newdb = backend.delete(db, key)
    {:reply, :ok, %{state | db: newdb}}
  end

  @impl true
  def handle_call({:read, key}, _from, state) do
    %{db: db, backend: backend} = state
    result = backend.read(db, key)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:match, value}, _from, state) do
    %{db: db, backend: backend} = state
    result = backend.match(db, value)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:records}, _from, state) do
    %{db: db, backend: backend} = state
    result = backend.records(db)
    {:reply, result, state}
  end
end
