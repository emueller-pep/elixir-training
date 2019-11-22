defmodule CrossRing do
  @moduledoc """
  Write a program that will create n processes connected in a ring. These processes will then
  send m number of messages around the ring. Halfway through the ring, however, the message
  will cross over the first process, which will then forward it to the second half of the ring.
  The ring should terminate gracefully when receiving a quit message.
  """

  @doc "start up the processes and connect them together"
  def start(n) do
    {:ok, pids} = RoutedRing.start(2 * n - 1, construct_routes(n))
    Process.register(List.first(pids), :ringleader)
    :ok
  end

  # list of 3-tuples indicating from-index, node-index, and to-index - n is the size of 
  # *each* ring, so we should have 2 * n - 1 nodes in total, but 2 * n routes
  def construct_routes(n) when n > 2 do
    Enum.concat([leader_routes(n), lefty_routes(n), righty_routes(n)])
  end

  defp leader_routes(n) do
    [
      {2 * n - 3, 2 * n - 2, 0},
      {2 * n - 2, 0, 1},
      {0, 1, 2},
      {n - 2, n - 1, 0},
      {n - 1, 0, n},
      {0, n, n + 1}
    ]
  end

  defp lefty_routes(n) when n <= 3 do
    []
  end

  defp lefty_routes(n) do
    Enum.map(2..(n - 2), fn i -> {i - 1, i, i + 1} end)
  end

  defp righty_routes(n) when n <= 3 do
    []
  end

  defp righty_routes(n) do
    Enum.map((n + 1)..(2 * n - 3), fn i -> {i - 1, i, i + 1} end)
  end

  @doc "send this message for N hops around the ring"
  def pass_message(message, n) do
    send(:ringleader, {:pass, nil, message, n - 1})
    :ok
  end

  @doc "ask the ringleader to tell all downstream nodes to halt"
  def stop_all do
    send(:ringleader, {:stop})
    :ok
  end
end
