ExUnit.start()

defmodule TempTest do
  use ExUnit.Case, async: true

  test "Temp.f2c" do
    assert_in_delta Temp.f2c(32), 0, 0.001
    assert_in_delta Temp.f2c(212), 100, 0.001
    assert_in_delta Temp.f2c(0), -17.8, 0.1
  end

  test "Temp.c2f" do
    assert_in_delta Temp.c2f(0), 32, 0.001
    assert_in_delta Temp.c2f(100), 212, 0.001
    assert_in_delta Temp.c2f(-17.8), 0.0, 0.1
  end
end
