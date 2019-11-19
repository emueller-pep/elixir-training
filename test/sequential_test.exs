ExUnit.start()

defmodule SequentialTest do
  use ExUnit.Case, async: true
  doctest Sequential

  test "Sequential.sum/1" do
    assert Sequential.sum(1) == 1
    assert Sequential.sum(5) == 15
    assert Sequential.sum(10) == 55
    catch_error Sequential.sum(-3)
  end

  test "Sequential.sum_interval/2" do
    assert Sequential.sum_interval(1, 5) == 15
    assert Sequential.sum_interval(3, 5) == 12
    assert Sequential.sum_interval(-4, -3) == -7
    assert Sequential.sum_interval(-1, 1) == 0
    catch_error Sequential.sum_interval(6, 5)
  end

  test "Sequence.create/1" do
    assert Sequential.create(1) == [1]
    assert Sequential.create(4) == [1, 2, 3, 4]
    catch_error Sequential.create(-2)
    catch_error Sequential.create(0)
  end

  test "Sequence.reverse_create/1" do
    assert Sequential.reverse_create(1) == [1]
    assert Sequential.reverse_create(4) == [4, 3, 2, 1]
    catch_error Sequential.reverse_create(-2)
    catch_error Sequential.reverse_create(0)
  end
end
