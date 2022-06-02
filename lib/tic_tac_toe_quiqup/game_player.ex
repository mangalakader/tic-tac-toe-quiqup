defmodule TicTacToeQuiqup.GamePlayer do
  @moduledoc """
  TicTacToe Game Player Specific Functions
  """

  @enforce_keys [:name, :letter]

  defstruct name: nil, letter: nil

  def init(name, letter), do: %__MODULE__{name: name, letter: letter}
end
