defmodule TicTacToeQuiqup.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TicTacToeQuiqup.Games` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{

      })
      |> TicTacToeQuiqup.Games.create_game()

    game
  end
end
