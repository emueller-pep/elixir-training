###############################################################################
### File: fussball.ex
### @author trainers@erlang-solutions.com
### @copyright 1999-2019 Erlang Solutions Ltd.
###############################################################################

defmodule Fussball do
  def easy() do
    start(:england, :spain)
    :timer.sleep(200)
    start(:spain, :england)
    :timer.sleep(200)
    kickoff(:spain)
  end

  def halt() do
    stop(:england)
    stop(:spain)
  end

  def start(mycountry, othercountry) do
    spawn(Fussball, :init, [mycountry, othercountry])
    :ok
  end

  def stop(country) do
    send(country, :stop)
  end

  def kickoff(country) do
    send(country, :kick)
    :ok
  end

  def init(mycountry, othercountry) do
    Process.flag(:trap_exit, true)
    Process.register(self(), mycountry)
    loop(mycountry, othercountry)
  end

  defp loop(mycountry, othercountry) do
    receive do
      :stop ->
        :ok

      :save ->
        IO.puts("#{othercountry} just saved...")
        loop(mycountry, othercountry)

      :score ->
        IO.puts("Oh no! #{othercountry} just scored!!")
        loop(mycountry, othercountry)

      :kick ->
        :timer.sleep(500)
        case :random.uniform(1000) do
          n when n > 950 ->
            IO.puts("#{mycountry} SAVES! And what a save!!")
            send(othercountry, :save)
            send(othercountry, :kick)
          n when n > 800 ->
              IO.puts("#{mycountry} SCORES!!")
              send(othercountry, :score)
          _ ->
            IO.puts("#{mycountry} kicks the ball...")
            send(othercountry, :kick)
        end
        loop(mycountry, othercountry)
    end
  end

end
