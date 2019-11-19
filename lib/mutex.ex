defmodule Mutex do
  @moduledoc """
  Write a process that will act as a binary semaphore providing mutual exclusion (mutex) for
  processes that want to share a resource. Model your process as a finite state machine with
  two states, busy and free. If a process tries to take the mutex (by calling Mutex.wait())
  when the process is in state busy, the function call should hang until the mutex becomes
  available (namely, the process holding the mutex calls Mutex.signal()). 
  
  Mutex.start() → :ok
  Mutex.wait() → :ok
  Mutex.signal() → :ok

  Hint: The difference in the state of your FSM is which messages you handle in which state.
  """

  def start(name) do
    pid = spawn(Mutex, :init, [])
    Process.register(pid, name)
    :ok
  end

  def wait(name) do
    send(name, { :wait, self() })
    receive do
      { :granted } -> :ok
    end
  end

  def signal(name) do
    send(name, { :signal, self() })
    receive do
      { :released } -> :ok
    end
  end

  def init do
    available()
  end

  defp available() do
    receive do
      { :wait, from } ->
        IO.puts("received a wait request from #{inspect from}")
        send(from, { :granted})
        IO.puts("send release to #{inspect from}")
        taken(from)
    end
  end

  defp taken(by_pid) do
    receive do
      { :signal, ^by_pid } ->
        IO.puts("received a signal from #{inspect by_pid}")
        send(by_pid, { :released })
        available()
    end
  end
end
