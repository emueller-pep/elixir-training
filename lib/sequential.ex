defmodule Sequential do
  @moduledoc """
  Implement exercises for section two of the training
  """

  @doc "sum of numbers from 1 to n"
  def sum(1) do 1 end
  def sum(n) when n > 1 do n + sum(n-1) end

  @doc "sum of numbers from n to m"
  def sum_interval(n, n) do n end
  def sum_interval(n, m) when m > n do m + sum_interval(n, m - 1) end

  @doc "create a list from 1 to n"
  def create(n) do create(1, n) end

  @doc "create a list from n to 1"
  def reverse_create(n) do Enum.reverse(create(n)) end

  defp create(a, a) do [a] end
  defp create(a, b) when b > a do [a | create(a + 1, b)] end

  @doc "print out the integers from 1 to n"
  def print(n) do print_list create(n) end

  @doc "print out the even integers from 1 to n"
  def even_print(n) do 
    create(n)
    |> Enum.filter(fn x -> rem(x, 2) == 0 end)
    |> print_list
  end

  defp print_list(list) do Enum.each(list, fn x -> IO.puts(x) end) end
end
