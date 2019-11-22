defmodule ProcessRing do
  @moduledoc """
  Write a program that will create n processes connected in a ring. These processes will then
  send m number of messages around the ring and then terminate gracefully when they receive a
  quit message.

  There are two basic strategies to tackling your problem. The first one is to have a central
  process that sets up the ring and initiates the message sending. The second strategy consists
  of the new process spawning the next process in the ring. With this strategy you have to find
  a method to connect the first process to the last.
  """

  @doc "start up the processes and connect them together"
  def start(n) do
    {:ok, pids} = RoutedRing.start(n, construct_routes(n))
    Process.register(List.first(pids), :ringleader)
    :ok
  end

  def construct_routes(n) when n > 1 do
    Enum.map(0..(n - 1), fn i -> {rem(i + n - 1, n), i, rem(i + 1, n)} end)
  end

  @doc "send this message for N hops around the ring"
  def pass_message(message, n) do
    send(:ringleader, {:pass, nil, message, n - 1})
    :ok
  end

  def stop_all do
    send(:ringleader, {:stop})
    :ok
  end
end
