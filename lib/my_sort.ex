defmodule MySort do
  @moduledoc """
  Implement sorting algorithms for exercise 2.6
  """

  @doc """
  Quicksort: The head of the list is taken as the pivot; the list is then split according to
  those elements smaller than the pivot and the rest. These two lists are then recursively
  sorted by quicksort and joined together with the pivot between them.
  """
  def quicksort([]) do
    []
  end

  def quicksort([x]) do
    [x]
  end

  def quicksort([pivot | rest]) do
    {below, above} = Manipulate.partition(rest, fn x -> x < pivot end)
    Manipulate.concatenate([quicksort(below), [pivot], quicksort(above)])
  end

  @doc """
  Mergesort: The list is split into two lists of (almost) equal length. These are then sorted
  separately and their result merged together.
  """
  def mergesort([]) do
    []
  end

  def mergesort([x]) do
    [x]
  end

  def mergesort(list) do
    {f, b} = Manipulate.split(list)
    sorted_merge({mergesort(f), mergesort(b)})
  end

  # This should merge two already-sorted lists together into a still-sorted list. It will
  # construct that list in reverse order, so we reverse it at the end.
  defp sorted_merge({sa, sb}) do
    sorted_merge([], sa, sb)
  end

  defp sorted_merge(output, [], sb) do
    Manipulate.concatenate([output, sb])
  end

  defp sorted_merge(output, sa, []) do
    Manipulate.concatenate([output, sa])
  end

  defp sorted_merge(output, [ha | sar], [hb | sbr]) do
    if ha < hb do
      sorted_merge(Manipulate.concatenate([output, [ha]]), sar, [hb | sbr])
    else
      sorted_merge(Manipulate.concatenate([output, [hb]]), [ha | sar], sbr)
    end
  end
end
