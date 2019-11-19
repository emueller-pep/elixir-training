ExUnit.start()

defmodule BooleanTest do
  use ExUnit.Case, async: true
  doctest Boolean

  test "Boolean.b_not" do
    assert Boolean.b_not(true) == false
    assert Boolean.b_not(false) == true
  end

  test "Boolean.b_and" do
    assert Boolean.b_and(true, true) == true
    assert Boolean.b_and(true, false) == false
    assert Boolean.b_and(false, true) == false
    assert Boolean.b_and(false, false) == false
  end

  test "Boolean.b_or" do
    assert Boolean.b_or(true, true) == true
    assert Boolean.b_or(true, false) == true
    assert Boolean.b_or(false, true) == true
    assert Boolean.b_or(false, false) == false
  end
end
