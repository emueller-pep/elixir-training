defmodule MyAgentTest do
  use ExUnit.Case, async: true

  test "new/1" do
    foo = 25
    agent = MyAgent.new(fn -> foo + 4 end)
    assert is_pid(agent)
  end

  test "get/2" do
    agent = MyAgent.new(fn -> 4 end)
    assert MyAgent.get(agent, fn(x) -> x end) == 4
  end

  test "update/2" do
    foo = 2
    agent = MyAgent.new(fn -> foo + 4 end)

    assert MyAgent.get(agent, fn(x) -> x end) == 6
    assert MyAgent.update(agent, fn(x) -> x * x end) == :ok
    assert MyAgent.get(agent, fn(x) -> x end) == 36
  end

  test "get_and_update/2" do
    foo = 2
    agent = MyAgent.new(fn -> foo + 4 end)

    assert MyAgent.get_and_update(agent, fn(x) -> {x * x, x + 1} end) == 36
    assert MyAgent.get(agent, fn(x) -> x end) == 7
  end
end
