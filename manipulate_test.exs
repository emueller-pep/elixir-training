ExUnit.start()

defmodule ManipulateTest do
  use ExUnit.Case, async: true

  test "Manipulate.filter/2" do
    assert Manipulate.filter([1, 2, 3, 4, 5, 6], 4) == [1, 2, 3, 4]
    assert Manipulate.filter([5, 3, 1, 12, 4, 4], 4) == [3, 1, 4, 4]
    assert Manipulate.filter([5, 5, 5], 4) == []
    assert Manipulate.filter([], 0) == []
  end

  test "Manipulate.reverse/1" do
    assert Manipulate.reverse([]) == []
    assert Manipulate.reverse([1, 2, 3, 4]) == [4, 3, 2, 1]
    assert Manipulate.reverse([:foo, 3, {:a, :b}]) == [{:a, :b}, 3, :foo]
  end

  test "Manipulate.concatenate/1" do
    assert Manipulate.concatenate([[1, 2], [3, 4], [5, 6]]) == [1, 2, 3, 4, 5, 6]
    assert Manipulate.concatenate([[:foo], [:bar], [:baz, :bam]]) == [:foo, :bar, :baz, :bam]
    assert Manipulate.concatenate([[1, 2, 3, 4], [3, 5], []]) == [1, 2, 3, 4, 3, 5]
  end

  test "Manipulate.flatten/1" do
    assert Manipulate.flatten([1, 2, 3]) == [1, 2, 3]
    assert Manipulate.flatten([[1, 2], [3, 4, 5], 6]) == [1, 2, 3, 4, 5, 6]
    assert Manipulate.flatten([[], []]) == []
  end

  test "Manipulate.map/2" do
    assert Manipulate.map([], fn(x) -> x + 1 end) == []
    assert Manipulate.map([1, 2, 3], fn(x) -> rem(x, 2) == 0 end) == [false, true, false]
    assert Manipulate.map([3, 4, 2], fn(x) -> x * x end) == [9, 16, 4]
  end

  test "Manipulate.partition/2" do
    assert Manipulate.partition([], fn -> true end) == { [], [] }
    assert Manipulate.partition([1, 3, 5, 2, 4], fn(x) -> x > 3 end) == {[5, 4], [1, 3, 2]}
    assert Manipulate.partition([1, 2, 3, 4, 5], fn(x) -> rem(x, 2) == 0 end) == {[2, 4], [1, 3, 5]}
  end

  test "Manipulate.split/1" do
    assert Manipulate.split([1,2,3,4]) == {[1,2], [3,4]}
    assert Manipulate.split('hellothere!') == {'hello', 'there!'}
    assert Manipulate.split([]) == {[], []}
    assert Manipulate.split('a') == {'', 'a'}
  end
end
