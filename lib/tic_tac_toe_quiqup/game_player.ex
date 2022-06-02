defmodule TicTacToeQuiqup.GamePlayer do
  @moduledoc """
  TicTacToe Game Player Specific Functions
  """

  @enforce_keys [:name, :letter]

  defstruct name: nil, letter: nil

  def init(name, letter), do: %__MODULE__{name: name, letter: letter}

  def validate_player(%__MODULE__{name: _name, letter: player_letter}), do: letter(player_letter)

  defp letter(player_letter) do
    cond do
      player_letter in ["X", "x", :x] -> {:ok, :x}
      player_letter in ["O", "o", :o] -> {:ok, :o}
      true -> {:error, :invalid_player}
    end
  end
end
