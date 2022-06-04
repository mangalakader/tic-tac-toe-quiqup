defmodule TicTacToeQuiqup.GamePlayerTest do
  @moduledoc """
  Unit Tests for GamePlayer Module
  """
  use TicTacToeQuiqup.DataCase, async: true

  alias TicTacToeQuiqup.GamePlayer

  describe "new/3" do
    @tag :unit
    test "all three params as user input" do
      assert {:ok, %GamePlayer{id: "random_id", name: "random_name", letter: :x}} =
               GamePlayer.new("random_id", "random_name", "x")
    end

    @tag :unit
    test "id as nil" do
      assert {:ok, %GamePlayer{id: _id, name: "random_name", letter: :x}} =
               GamePlayer.new(nil, "random_name", "x")
    end

    @tag :unit
    test "id as empty quotes" do
      assert {:ok, %GamePlayer{id: _id, name: "random_name", letter: :x}} =
               GamePlayer.new("", "random_name", "x")
    end

    @tag :unit
    test "invalid player letter" do
      assert {:error, "Invalid player"} = GamePlayer.new("", "random_name", "z")
    end
  end

  describe "new_x/1" do
    @tag :unit
    test "name is given" do
      assert {:ok, %GamePlayer{id: _id, name: "random_name", letter: :x}} =
               GamePlayer.new_x("random_name")
    end
  end

  describe "new_o/1" do
    @tag :unit
    test "name is given" do
      assert {:ok, %GamePlayer{id: _id, name: "random_name", letter: :o}} =
               GamePlayer.new_o("random_name")
    end
  end

  describe "validate_player/1" do
    setup do
      {:ok, player} = GamePlayer.new("valid_id", "valid_name", "x")

      {:ok, player: player}
    end

    @tag :unit
    test "valid player given as input", %{player: player} do
      assert {:ok, :x} = GamePlayer.validate_player(player)
    end

    @tag :unit
    test "invalid player given as input", %{player: player} do
      assert {:error, "Invalid player"} = GamePlayer.validate_player(%{player | letter: :z})
    end
  end
end
