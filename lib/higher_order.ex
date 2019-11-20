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

  # Using funs and higher order functions, write a function which prints out the even integers
  # between 1 and n. Hint: Solve your problem either in two steps, or use two clauses in your fun.
  @doc "produce the evven integers from 1-n"
  def select_evens_to(n) when n > 0 do
    even? = fn(x) -> rem(x, 2) == 0 end
    Enum.filter((1..n), even?)
  end

  # Using funs and higher order functions, write a function which, given a list of lists,
  # will concatenate them.
  @doc "concatenate a list of lists"
  def concatenate([]) do [] end
  def concatenate(lol) do
    concat2 = fn(list, acc) -> acc ++ list end;
    Enum.reduce(lol, concat2)
  end
end
