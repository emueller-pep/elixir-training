defmodule Boolean do
  @moduledoc """
  Reimplement simple boolean logic
  """

  @doc "strict reimplementation of a boolean NOT"
  def b_not(true) do
    false
  end

  def b_not(false) do
    true
  end

  @doc "strict reimplementation of a boolean AND"
  def b_and(true, true) do
    true
  end

  def b_and(_, _) do
    false
  end

  @doc "strict reimplementation of a boolean OR"
  def b_or(false, false) do
    false
  end

  def b_or(_, _) do
    true
  end
end
