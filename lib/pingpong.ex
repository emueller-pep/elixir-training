###############################################################################
### File: pingpong.ex
### @author trainers@erlang-solutions.com
### @copyright 1999-2019 Erlang Solutions Ltd.
###############################################################################

defmodule Pingpong do
  def start() do
    pid_a = spawn(Pingpong, :init_a, [])
    Process.register(pid_a, :a)
    Process.register(spawn(Pingpong, :init_b, [pid_a]), :b)
    :ok
  end

  def stop() do
    send(:a, :stop)
  end

  def send(n) do
    send(:a, {:msg, :message, n})
    :ok
  end

  def init_a() do
    loop_a()
  end

  def init_b(pid_a) do
    Process.link(pid_a)
    loop_b()
  end

  defp loop_a() do
    receive do
      :stop ->
        exit("ouch")

      {:msg, _msg, 0} ->
        loop_a()

      {:msg, msg, n} ->
        IO.puts("ping...")
        :timer.sleep(500)
        send(:b, {:msg, msg, n - 1})
        loop_a()
    after
      15000 ->
        IO.puts("Ping got bored, exiting.")
        exit(:timeout)
    end
  end

  defp loop_b() do
    receive do
      {:msg, _msg, 0} ->
        loop_b()

      {:msg, msg, n} ->
        IO.puts("pong!")
        :timer.sleep(500)
        send(:a, {:msg, msg, n - 1})
        loop_b()
    after
      15000 ->
        IO.puts("Pong got bored, exiting.")
        exit(:timeout)
    end
  end

end
