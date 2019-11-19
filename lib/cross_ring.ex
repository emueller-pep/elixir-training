defmodule CrossRing do
  @moduledoc """
  Write a program that will create n processes connected in a ring. These processes will then
  send m number of messages around the ring. Halfway through the ring, however, the message
  will cross over the first process, which will then forward it to the second half of the ring.
  The ring should terminate gracefully when receiving a quit message.
  """

  @doc "start up the processes and connect them together"
  def start(n) do
    pids = Enum.map((0..2*n-2), fn(i) -> spawn(CrossRing, :start_loop, [i]) end)
    Enum.each(construct_routes(n), fn({pi, i, ni}) ->
      [prev, node, next] = values_at(pids, [pi, i, ni])
      send(node, { :add_route, prev, next })
    end)

    Process.register(List.first(pids), :ringleader)
    :ok
  end

  # list of 3-tuples indicating from-index, node-index, and to-index - n is the size of 
  # *each* ring, so we should have 2 * n - 1 nodes in total, but 2 * n routes
  def construct_routes(n) when n > 2 do
    Enum.concat([leader_routes(n), lefty_routes(n), righty_routes(n)])
  end

  defp leader_routes(n) do [{2*n-3, 2*n-2, 0}, {2*n-2, 0, 1}, {0, 1, 2}, {n-2, n-1, 0}, {n-1, 0, n}, {0, n, n+1}] end

  defp lefty_routes(n) when n <= 3 do [] end
  defp lefty_routes(n) do Enum.map((2..n-2), fn(i) -> {i-1, i, i+1} end) end

  defp righty_routes(n) when n <= 3 do [] end
  defp righty_routes(n) do Enum.map((n+1..(2*n - 3)), fn(i) -> {i-1, i, i+1} end) end

  defp values_at(list, indices) do
    Enum.map(indices, fn(i) -> Enum.at(list, i) end)
  end

  @doc "receive-loop for each item in the ring"
  def start_loop(n) do
    loop(n, [])
  end

  @doc "send this message for N hops around the ring"
  def pass_message(message, n) do
    send(:ringleader, { :pass, nil, message, n - 1 })
    :ok
  end

  def stop_all do
    send(:ringleader, { :stop })
    :ok
  end

  defp loop(n, routes) do
    receive do
      { :add_route, prev, next } ->
        IO.puts("Adding route #{inspect prev} -> #{inspect self()} -> #{inspect next} to node #{n}")
        loop(n, [{prev, next} | routes])
      { :stop } ->
        Enum.each(routes, fn({_prev, next}) -> send(next, { :stop }) end)
        IO.puts("Node #{n} is halting")
        :ok
      { :pass, _, message, 0 } ->
        handle_terminal_message(n, message)
        loop(n, routes)
      { :pass, nil, message, hops_remaining } ->
        handle_sourceless_message(n, routes, message, hops_remaining)
        loop(n, routes)
      { :pass, from, message, hops_remaining } ->
        pass_message_along(n, routes, from, message, hops_remaining)
        loop(n, routes)
    end
  end

  defp handle_terminal_message(n, message) do
    IO.puts("Node #{n} received message #{inspect message}, no hops left")
  end

  defp handle_sourceless_message(n, routes, message, hops_remaining) do
    Enum.each(routes, fn({p,n}) -> IO.puts "Considering route #{inspect p} -> #{inspect n}" end);
    { _prev, next } = List.last(routes)
    IO.puts("Node #{n} received message #{inspect message}, #{hops_remaining} hops left")
    send(next, { :pass, self(), message, hops_remaining - 1 })
  end

  defp pass_message_along(n, routes, from, message, hops_remaining) do
    IO.puts("Node #{n} received message #{inspect message} from #{inspect from}, #{hops_remaining} hops left")
    Enum.each(routes, fn({p,n}) -> IO.puts "Considering route #{inspect p} -> #{inspect n}" end);

    routes
    |> Enum.filter(fn({prev, _next}) -> from == prev end)
    |> Enum.each(fn({_prev, next}) -> send(next, { :pass, self(), message, hops_remaining - 1 }) end)
  end
end
