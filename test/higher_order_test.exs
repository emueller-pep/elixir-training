defmodule HigherOrderTest do
  use ExUnit.Case, async: true
  doctest HigherOrder

  test "select_below/2" do
    assert HigherOrder.select_below([1, 3, 2, 6, 5, 4], 4) == [1, 3, 2]
    assert HigherOrder.select_below([1, 2, 3], 1) == []
    assert HigherOrder.select_below([], 55) == []
  end

  test "select_below_2/2" do
    assert HigherOrder.select_below_2([1, 3, 2, 6, 5, 4], 4) == [1, 3, 2]
    assert HigherOrder.select_below_2([1, 2, 3], 1) == []
    assert HigherOrder.select_below_2([], 55) == []
  end

  test "select_evens_to/1" do
    assert HigherOrder.select_evens_to(1) == []
    assert HigherOrder.select_evens_to(8) == [2, 4, 6, 8]
    assert HigherOrder.select_evens_to(5) == [2, 4]
    catch_error HigherOrder.select_evens_to(-1)
  end

  test "concatenate/1" do
    assert HigherOrder.concatenate([[1, 2], [], [3], [4, 5, 6]]) == [1, 2, 3, 4, 5, 6]
    assert HigherOrder.concatenate([]) == []
    assert HigherOrder.concatenate([[], []]) == []
  end
end
