defmodule MyAgent do
  use GenServer

  @moduledoc """
  Exercise to reimplement Agent
  new(fn -> initial_value end) -> {:ok, pid}
  update(agent, fn(oldval) -> newval end) -> :ok
  get(agent, fn(value) -> return_value end) -> return value
  get_and_update(agent, fn(fn(value) -> {newval, retval} end)) -> retval
  """

  def new(init_callback) do
    {:ok, agent} = GenServer.start_link(MyAgent, init_callback)
    agent
  end

  def update(agent, updater) do
    GenServer.cast(agent, {:update, updater})
  end

  def get(agent, transformer) do
    GenServer.call(agent, {:get, transformer})
  end

  def get_and_update(agent, transformer_updater) do
    GenServer.call(agent, {:get_and_update, transformer_updater})
  end

  @impl true
  def init(init_callback) do
    {:ok, init_callback.()}
  end

  ## Message Handlers

  @impl true
  def handle_cast({:update, updater}, value) do
    {:noreply, updater.(value)}
  end

  @impl true
  def handle_call({:get, transformer}, _from, value) do
    {:reply, transformer.(value), value}
  end

  @impl true
  def handle_call({:get_and_update, update_transformer}, _from, value) do
    {return_value, new_value} = update_transformer.(value)
    {:reply, return_value, new_value}
  end
end
