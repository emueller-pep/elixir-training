defmodule MySortTest do
  use ExUnit.Case, async: true
  doctest MySort

  test "MySort.quicksort" do
    assert MySort.quicksort([1, 2, 3, 4, 5]) == [1, 2, 3, 4, 5]
    assert MySort.quicksort([5, 2, 1, 4, 3]) == [1, 2, 3, 4, 5]
    assert MySort.quicksort([5, 1, 4, 3]) == [1, 3, 4, 5]
    assert MySort.quicksort([5, 4, 3, 2, 1]) == [1, 2, 3, 4, 5]
  end

  test "MySort.mergesort" do
    #assert MySort.mergesort([1, 2, 3, 4, 5]) == [1, 2, 3, 4, 5]
    assert MySort.mergesort([5, 2, 1, 4, 3]) == [1, 2, 3, 4, 5]
    #assert MySort.mergesort([5, 1, 4, 3]) == [1, 3, 4, 5]
    #assert MySort.mergesort([5, 4, 3, 2, 1]) == [1, 2, 3, 4, 5]
  end
end
