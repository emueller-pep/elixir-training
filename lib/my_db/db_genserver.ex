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
  def handle_cast({:write, key, value}, %{db: db, backend: backend}) do
    {:noreply, %{db: backend.write(db, key, value), backend: backend}}
  end

  @impl true
  def handle_cast({:delete, key}, %{db: db, backend: backend}) do
    {:noreply, %{db: backend.delete(db, key), backend: backend}}
  end

  @impl true
  def handle_call({:write, key, value}, _from, %{db: db, backend: backend}) do
    {:reply, :ok, %{db: backend.write(db, key, value), backend: backend}}
  end

  @impl true
  def handle_call({:delete, key}, _from, %{db: db, backend: backend}) do
    {:reply, :ok, %{db: backend.delete(db, key), backend: backend}}
  end

  @impl true
  def handle_call({:read, key}, _from, %{db: db, backend: backend}) do
    {:reply, backend.read(db, key), %{db: db, backend: backend}}
  end

  @impl true
  def handle_call({:match, value}, _from, %{db: db, backend: backend}) do
    {:reply, backend.match(db, value), %{db: db, backend: backend}}
  end

  @impl true
  def handle_call({:records}, _from, %{db: db, backend: backend}) do
    {:reply, backend.records(db), %{db: db, backend: backend}}
  end
end
