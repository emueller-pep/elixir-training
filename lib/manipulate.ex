defmodule Manipulate do
  @moduledoc """
  Work for 2.5 (ADVANCED: Manipulating Lists)
  """

  @doc "filter out values failing a supplied predicate function"
  def filter(list, function) do Manipulate.reverse(filter([], list, function)) end

  defp filter(output, [], _function) do output end
  defp filter(output, [record | remaining], function) do
    if function.(record) do
      filter([record | output], remaining, function)
    else
      filter(output, remaining, function)
    end
  end


  @doc """
  Given a list of integers, return all the values <= to a supplied value,
  retaining the initial ordering of all values
  """
  def filtern(list, n) do filter(list, fn(x) -> x <= n end) end

  @doc """
  Given a list, produce a list which contains the same elements in the opposite order.
  """
  def reverse(list) do reverse([], list) end

  defp reverse(output, []) do output end
  defp reverse(output, [head | rest]) do reverse([head | output], rest) end

  @doc "Given a list of lists, concatenate them all together in order"
  def concatenate(list) do concatenate([], list) end

  ## We are handling the array of arrays in reverse order, but *also* handling the individual
  ## arrays in reverse order, which means that we can just reverse the *final output* and it
  ## will be in the correct order.
  defp concatenate(output, []) do reverse(output) end
  defp concatenate(output, [next_list | remaining]) do concatenate(rconcat2(next_list, output), remaining) end

  defp rconcat2([], l2) do l2 end
  defp rconcat2([r1_head | r1_rest], l2) do rconcat2(r1_rest, [r1_head | l2]) end

  @doc "apply a supplied function to every item in a list and return the results"
  def map(list, function) do reverse(map([], list, function)) end

  defp map(output, [], _function) do output end
  defp map(output, [head | rest], function) do map([function.(head) | output], rest, function) end

  @doc "take a nested list of lists and turn it into a list containing no lists"
  def flatten(lol) when not is_list(lol) do [lol] end
  def flatten(lol) do concatenate(map(lol, &flatten/1)) end

  # returns a tuple of two lists - the first one contains all elements that satisfy the predicate
  # and the second one everything else (both in stable order)
  @doc "produce a 2-tuple of lists, one containing all matches and the other containing the rest"
  def partition(list, predicate) do 
    { yes, no } = partition(list, predicate, [], [])
    { Manipulate.reverse(yes), Manipulate.reverse(no) }
  end

  defp partition([], _predicate, yes, no) do { yes, no } end
  defp partition([item | rest], predicate, yes, no) do
    if predicate.(item) do
      partition(rest, predicate, [item | yes], no)
    else
      partition(rest, predicate, yes, [item | no])
    end
  end

  @doc """
  split a supplied list roughly in half (the latter half is larger if the list has an odd
  length). Return a tuple of {first_half, second_half}.
  """
  def split(list) do
    { front, back } = split([], list, div(length(list), 2))
    { reverse(front), back }
  end

  defp split(front, back, 0) do { front, back } end
  defp split(front, [], _remaining) do { front, [] } end
  defp split(front, [item | back_rest], remaining) do
    split([item | front], back_rest, remaining - 1)
  end
end
