defmodule Temp do
  @moduledoc """
  Perform basic temperature conversions
  """

  @doc "Convert a fahrenheit temperature to celsius"
  def f2c(temperature_in_f) do
    (temperature_in_f - 32) * 5 / 9
  end

  @doc "Convert a celsius temperature to fahrenheit "
  def c2f(temperature_in_c) do
    (temperature_in_c * 9 / 5) + 32
  end

  @doc "Convert a temperature to another system"
  def convert({:c, temperature_in_c}) do c2f(temperature_in_c) end
  def convert({:f, temperature_in_f}) do f2c(temperature_in_f) end
end
