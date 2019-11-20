defmodule HigherOrder do
  @moduledoc """
  Implementations of exercises in 6.3
  """

  @doc "Using funs and higher order functions, write a function which prints out the integers between 1 and n"
  def print_to(n) do Enum.each(1..n, fn(i) -> IO.puts(i) end) end

  @doc "print the integers from 1->n using anonymous per-value printer funs"
  def print_to_2(n) do
    (1..n)
    |> Enum.map(fn(i) -> (fn -> IO.puts(i) end) end)  # generate an array of printer methods
    |> Enum.each(fn(f) -> f.() end)                   # invoke them
  end

  # Using funs and higher order functions, write a function which given a list of integers and an
  # integer, will return all integers smaller than or equal to that integer.
  @doc "find items below a supplied threshold"
  def select_below(list, threshold) do Enum.filter(list, fn(i) -> i < threshold end) end

  @doc "find items below a threshold using an anonymous filter function"
  def select_below_2(list, threshold) do
    below_threshold? = fn(i) -> i < threshold end
    Enum.filter(list, below_threshold?)
  end
end
