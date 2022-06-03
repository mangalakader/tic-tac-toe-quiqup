defmodule TicTacToeQuiqup.GamePlayer do
  @moduledoc """
  TicTacToe Game Player Specific Functions
  """
  @enforce_keys [:id, :name, :letter]

  require Protocol

  import TicTacToeQuiqup.Utilities, only: [generate_rand_str: 1]

  defstruct id: nil, name: nil, letter: nil

  def new(nil, name, letter), do: new(generate_rand_str(12), name, letter)
  def new("", name, letter), do: new(generate_rand_str(12), name, letter)

  def new(id, name, letter) do
    case letter(letter) do
      {:ok, atom_letter} ->
        {:ok, %__MODULE__{id: id, name: name, letter: atom_letter}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def new_x(name), do: new(generate_rand_str(12), name, :x)
  def new_o(name), do: new(generate_rand_str(12), name, :o)

  def validate_player(%__MODULE__{name: _name, letter: player_letter}), do: letter(player_letter)

  defp letter(player_letter) do
    cond do
      player_letter in ["X", "x", :x] -> {:ok, :x}
      player_letter in ["O", "o", :o] -> {:ok, :o}
      true -> {:error, "Invalid player"}
    end
  end

  Protocol.derive(Jason.Encoder, __MODULE__)
end
