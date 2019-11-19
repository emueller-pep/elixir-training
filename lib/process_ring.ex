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
    pids = Enum.map(1..n, fn(x) ->
      spawn(ProcessRing, :start_loop, [x - 1])
    end)

    Enum.each(1..n, fn(number) ->
      [target, next] = ring_slice(pids, number - 1, 0, 1)
      send(target, {:init, next})
    end)

    Process.register(List.first(pids), :ringleader)
    :ok
  end

  defp ring_slice(list, index, start_offset, end_offset) do
    len = length(list)
    range = (index + start_offset .. index + end_offset)
    Enum.map(range, fn(n) -> Enum.at(list, modulo(n, len)) end)
  end

  defp modulo(n, max) when n < 0 do max + rem(n, max) end
  defp modulo(n, max) do rem(n, max) end

  @doc "receive-loop for each item in the ring"
  def start_loop(n) do
    loop(n, nil)
  end

  @doc "send this message for N hops around the ring"
  def pass_message(message, n) do
    send(:ringleader, { :pass, message, n })
  end

  defp loop(n, nil) do
    receive do
      { :init, next } -> loop(n, next)
      { :stop } -> :ok
    end
  end

  defp loop(n, next) do
    receive do
      { :pass, message, 0 } ->
        IO.puts("Process #{n} (#{inspect self()}) received #{message}, but it can go no further")
        loop(n, next)
      { :pass, message, remaining_hops } ->
        IO.puts("Process #{n} (#{inspect self()}) received #{message}, #{remaining_hops} left")
        send(next, {:pass, message, remaining_hops - 1})
        loop(n, next)
      { :stop } -> :ok
    end
  end
end
