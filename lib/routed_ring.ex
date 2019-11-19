defmodule RoutedRing do
  @moduledoc """
  A slightly general facility for managing nodes and a routing table among them,
  allowing messages to be passed for N hops along the route.
  """

  @doc "start up the processes and connect them together"
  def start(node_count, routes) do
    pids = Enum.map((0..node_count-1), fn(i) -> spawn(RoutedRing, :start_loop, [i]) end)
    Enum.each(routes, fn({pi, i, ni}) ->
      [prev, node, next] = values_at(pids, [pi, i, ni])
      send(node, { :add_route, prev, next })
    end)

    { :ok, pids }
  end

  defp values_at(list, indices) do
    Enum.map(indices, fn(i) -> Enum.at(list, i) end)
  end

  @doc "receive-loop for each item in the ring"
  def start_loop(n) do
    loop(n, [])
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
