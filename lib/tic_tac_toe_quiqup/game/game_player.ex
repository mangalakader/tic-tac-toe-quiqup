defmodule TicTacToeQuiqup.GamePlayer do
  @moduledoc """
  TicTacToe Game Player Specific Functions and any validation or functional
  rules for player data will have to done through here
  """
  @enforce_keys [:id, :name, :letter]

  require Protocol

  alias TicTacToeQuiqup.Types.Errors
  alias TicTacToeQuiqup.Types.GamePlayer, as: GamePlayerSpec

  import TicTacToeQuiqup.Utilities, only: [generate_rand_str: 1]

  defstruct id: nil, name: nil, letter: nil

  @doc """
  GamePlayer new function takes 3 arguments id, name and letter and returns a
  GamePlayer struct, it also has capabilities to generate id's if not provided

  ## Examples

  Using the new function with id as nil

  ```elixir
  iex> {:ok, %TicTacToeQuiqup.GamePlayer{name: "HELLO", letter: :x}} = 
  ...> TicTacToeQuiqup.GamePlayer.new(nil, "HELLO", "X")

  ```

  Using the new function with id as empty string

  ```elixir
  iex> {:ok, %TicTacToeQuiqup.GamePlayer{name: "HELLO", letter: :x}} = 
  ...> TicTacToeQuiqup.GamePlayer.new("", "HELLO", "X")

  ```

  Using the new function with id provided by user

  ```elixir
    iex> TicTacToeQuiqup.GamePlayer.new("RANDOM", "HELLO", "X")
    {:ok,
     %TicTacToeQuiqup.GamePlayer{
       id: "RANDOM",
       letter: :x,
       name: "HELLO"
     }}
    
  ```
    
  Using the new function with invalid letter

  ```elixir
    iex> TicTacToeQuiqup.GamePlayer.new("RANDOM", "HELLO", "Z")
    {:error, "Invalid player"}
    
  ```

  """
  @spec new(binary() | nil, binary() | nil, GamePlayerSpec.letters()) ::
          {:ok, GamePlayerSpec.t()} | Errors.t()
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

  @doc """
  GamePlayer new_x function takes 1 arguments name and returns a
  GamePlayer struct with letter as :x

  ## Examples

  Using the new_x function

  ```elixir
  iex> {:ok, %TicTacToeQuiqup.GamePlayer{name: "HELLO", letter: :x}} = 
  ...> TicTacToeQuiqup.GamePlayer.new_x("HELLO")

  ```

  """
  @spec new_x(binary() | nil) :: {:ok, GamePlayerSpec.t()} | Errors.t()
  def new_x(name), do: new(generate_rand_str(12), name, :x)

  @doc """
  GamePlayer new_o function takes 1 arguments name and returns a
  GamePlayer struct with letter as :o

  ## Examples

  Using the new_x function

  ```elixir
  iex> {:ok, %TicTacToeQuiqup.GamePlayer{name: "HELLO", letter: :o}} = 
  ...> TicTacToeQuiqup.GamePlayer.new_o("HELLO")

  ```

  """
  @spec new_o(binary() | nil) :: {:ok, GamePlayerSpec.t()} | Errors.t()
  def new_o(name), do: new(generate_rand_str(12), name, :o)

  @doc """
  GamePlayer validate_player function takes 1 arguments GamePlayer struct
  and validates the players letter for :x or :o and if not it returns an error

  ## Examples

  Using the validate_player function for x player

  ```elixir
    iex> {:ok, player} = TicTacToeQuiqup.GamePlayer.new_x("HELLO")
    iex> {:ok, :x} = TicTacToeQuiqup.GamePlayer.validate_player(player)
    
  ```

  Using the validate_player function for o player

  ```elixir
    iex> {:ok, player} = TicTacToeQuiqup.GamePlayer.new_o("HELLO")
    iex> {:ok, :o} = TicTacToeQuiqup.GamePlayer.validate_player(player)
    
  ```

  Using the validate_player function for invalid player

  ```elixir
    iex> {:ok, player} = TicTacToeQuiqup.GamePlayer.new_x("HELLO")
    iex> {:error, "Invalid player"} = TicTacToeQuiqup.GamePlayer.validate_player(%{player|letter: "Z"})
    
  ```

  """
  @spec validate_player(GamePlayerSpec.t()) :: {:ok, :x | :o} | Errors.t()
  def validate_player(%__MODULE__{name: _name, letter: player_letter}), do: letter(player_letter)

  @spec letter(GamePlayerSpec.letters()) :: {:ok, :x | :o} | Errors.t()
  defp letter(player_letter) do
    cond do
      player_letter in ["X", "x", :x] -> {:ok, :x}
      player_letter in ["O", "o", :o] -> {:ok, :o}
      true -> {:error, "Invalid player"}
    end
  end

  Protocol.derive(Jason.Encoder, __MODULE__)
end
