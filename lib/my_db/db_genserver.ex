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

    def lock do
      GenServer.call(MyDb.DbGenserver, {:lock, self()})
    end

    def unlock do
      GenServer.call(MyDb.DbGenserver, {:unlock, self()})
    end

    def write(key, value) do
      GenServer.call(MyDb.DbGenserver, {:write, self(), key, value})
    end

    def delete(key) do
      GenServer.call(MyDb.DbGenserver, {:delete, self(), key})
    end

    def read(key) do
      GenServer.call(MyDb.DbGenserver, {:read, self(), key})
    end

    def match(value) do
      GenServer.call(MyDb.DbGenserver, {:match, self(), value})
    end

    def write_async(key, value) do
      GenServer.cast(MyDb.DbGenserver, {:write, self(), key, value})
      :ok
    end

    def delete_async(key) do
      GenServer.cast(MyDb.DbGenserver, {:delete, self(), key})
      :ok
    end
  end

  ## GenServer callbacks ------------------------------------------------------

  @impl true
  def init(backend) do
    {:ok, %{db: backend.new, backend: backend, locked_by: nil}}
  end

  @impl true
  def terminate(_reason, %{db: db, backend: backend}) do
    backend.destroy(db)
  end

  ## Message handlers

  defp accessible?(state, pid), do: Enum.member?([nil, pid], state[:locked_by])

  @impl true
  def handle_cast({:write, caster, key, value}, state) do
    if accessible?(state, caster) do
      %{db: db, backend: backend} = state
      newdb = backend.write(db, key, value)
      {:noreply, %{state | db: newdb}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_cast({:delete, caster, key}, state) do
    if accessible?(state, caster) do
      %{db: db, backend: backend} = state
      newdb = backend.delete(db, key)
      {:noreply, %{state | db: newdb}}
    else
      {:noreply, state}
    end
  end

  @impl true
  def handle_call({:lock, caller}, _from, state) do
    if accessible?(state, caller) do
      {:reply, :ok, %{state | locked_by: caller}}
    else
      {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:unlock, caller}, _from, state) do
    if accessible?(state, caller) do
      {:reply, :ok, %{state | locked_by: nil}}
    else
      {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:write, caller, key, value}, _from, state) do
    if accessible?(state, caller) do
      %{db: db, backend: backend} = state
      newdb = backend.write(db, key, value)
      {:reply, :ok, %{state | db: newdb}}
    else
      {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:delete, caller, key}, _from, state) do
    if accessible?(state, caller) do
      %{db: db, backend: backend} = state
      newdb = backend.delete(db, key)
      {:reply, :ok, %{state | db: newdb}}
    else
      {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:read, caller, key}, _from, state) do
    if accessible?(state, caller) do
      %{db: db, backend: backend} = state
      result = backend.read(db, key)
      {:reply, result, state}
    else
      {:reply, {:error, :locked}, state}
    end
  end

  @impl true
  def handle_call({:match, caller, value}, _from, state) do
    if accessible?(state, caller) do
      %{db: db, backend: backend} = state
      result = backend.match(db, value)
      {:reply, result, state}
    else
      {:reply, {:error, :locked}, state}
    end
  end

  @impl true
  def handle_call({:records, caller}, _from, state) do
    if accessible?(state, caller) do
      %{db: db, backend: backend} = state
      result = backend.records(db)
      {:reply, result, state}
    else
      {:reply, {:error, :locked}, state}
    end
  end
end
