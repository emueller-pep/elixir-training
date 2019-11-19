defmodule Demo do
  @moduledoc """
  This is a demo module documentation
  """

  ## This is a comment, everything after '#' is ignored.
  
  @doc "Double the argument"
  def double(x) do
    times(x, 2)
  end

  defp times(x, n) do x * n end
end
