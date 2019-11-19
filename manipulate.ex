defmodule Manipulate do
  @moduledoc """
  Work for 2.5 (ADVANCED: Manipulating Lists)
  """

  @doc """
  Given a list of integers, return all the values <= to a supplied value,
  retaining the initial ordering of all values
  """
  def filter(list, n) do filter([], list, n) end
  def filter(output, [], _n) do reverse(output) end
  def filter(output, [head | rest], n) do
    if head <= n do
      filter([head | output], rest, n)
    else
      filter(output, rest, n)
    end
  end

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

  defp map(list, function) do reverse(map([], list, function)) end
  defp map(output, [], _function) do output end
  defp map(output, [head | rest], function) do map([function.(head) | output], rest, function) end

  @doc "take a nested list of lists and turn it into a list containing no lists"
  def flatten(lol) when not is_list(lol) do [lol] end
  def flatten(lol) do concatenate(map(lol, &flatten/1)) end
end
