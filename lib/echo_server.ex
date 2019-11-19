defmodule EchoServer do
  # @moduledoc """
  # Write a server which will wait in a receive loop until a message is sent to it. Depending on
  # the message, it should either print it and loop again or terminate. You want to hide the fact
  # that you are dealing with a process, and access its services through a functional interface.
  # These functions will spawn the process and send messages to it. The module Echo should export
  # the following functions.

  # Echo.start() → :ok
  # Echo.stop() → :ok
  # Echo.print(term) → :ok<Paste>

  # Hint: Use the Process.register/2 built in function.
  # Warning: Use an internal message protocol to avoid stopping the process when you for example
  # call the function Echo.print(:stop)
  # """

  @doc "start the receive-loop and return the server reference"
  def start() do
    echo_pid = spawn(EchoServer, :loop, [])
    Process.register(echo_pid, :echo_server)
    :ok
  end

  @doc "request that the supplied server halt its receive-loop"
  def stop do
    send(:echo_server, { :stop })
    :ok
  end

  @doc "request that the supplied server print out a particular message"
  def print(message) do 
    send(:echo_server, { :print, message })
    :ok
  end

  @doc "receive-loop for the echo-server"
  def loop do
    receive do
      { :print, message } -> IO.puts(message); loop()
      { :stop } -> :ok
    end
  end
end

