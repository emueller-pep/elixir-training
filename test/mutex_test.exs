defmodule MutexTest do
  use ExUnit.Case, asyn: false
  doctest Mutex

  test "single-threaded mutex use" do
    assert Mutex.start(:single_threaded_test) == :ok
    assert Mutex.wait(:single_threaded_test) == :ok
    assert Mutex.wait(:single_threaded_test) == :ok
    assert Mutex.signal(:single_threaded_test) == :ok
  end

  def loop(mutex_name, owner) do
    receive do
      :stop ->
        send(owner, { self(), :stopped })
        :ok
      :take ->
        Mutex.wait(mutex_name)
        send(owner, { self(), :taken })
        loop(mutex_name, owner)
      :release ->
        Mutex.signal(mutex_name)
        send(owner, { self(), :released })
        loop(mutex_name, owner)
      :ping ->
        send(owner, { self(), :pong })
        loop(mutex_name, owner)
      :die ->
        Process.exit(self(), :intentional)
      _ ->
        send(owner, { self(), :error })
        loop(mutex_name, owner)
    end
  end

  def call(pid, command, timeout) do
    send(pid, command)
    receive do
      { ^pid, response } -> response
    after
      timeout -> :timeout
    end
  end

  test "the testing setup loop" do
    assert Mutex.start(:testing_setup) == :ok
    pid = spawn(MutexTest, :loop, [:testing_setup, self()])
    IO.puts "The spawned pid is #{inspect pid}"
    IO.puts "The test script's pid is #{inspect self()}"
    assert call(pid, :ping, 50) == :pong
    assert call(pid, :ping, 50) == :pong
    assert call(pid, :foo, 50) == :error
    assert call(pid, :stop, 50) == :stopped
  end

  test "multi-threaded mutex use" do
    assert Mutex.start(:multi) == :ok

    abe = spawn(MutexTest, :loop, [:multi, self()])
    assert call(abe, :ping, 50) == :pong

    ben = spawn(MutexTest, :loop, [:multi, self()])
    assert call(ben, :ping, 50) == :pong

    assert call(abe, :take, 50) == :taken
    assert call(abe, :release, 50) == :released

    assert call(ben, :take, 50) == :taken
    assert call(abe, :take, 50) == :timeout
    assert call(ben, :take, 50) == :taken
    assert call(ben, :release, 50) == :released
    assert call(abe, :take, 50) == :taken

    call(abe, :stop, 50)
    call(ben, :stop, 50)
  end

  test "exit handling" do
    assert Mutex.start(:error_handling) == :ok
    abe = spawn(MutexTest, :loop, [:error_handling, self()])
    ben = spawn(MutexTest, :loop, [:error_handling, self()])

    assert call(abe, :take, 50) == :taken
    assert call(ben, :take, 50) == :timeout

    send(abe, :die)
    assert call(ben, :take, 50) == :taken
  end
end
