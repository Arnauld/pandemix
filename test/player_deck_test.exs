defmodule PlayerDeckTest do
  use ExUnit.Case
  doctest InfectionDeck

  test "discard pile is empty by default" do
    cards = [:paris, :epidemic, :london, :madrid, :algiers, :essen, :new_york]
    PlayerDeck.start_link(cards)
    assert [] == PlayerDeck.discard_pile()
  end


  test "draw cards" do
    cards = [:paris, :epidemic, :london, :madrid, :algiers, :essen, :new_york]
    PlayerDeck.start_link(cards, &Funs.identity/1)

    {:ok, ref} = PlayerDeck.draw(2, self())
    receive do
    	{:player_cards_drawn, ref0, drawns} ->
    		assert ref0 == ref
    		assert drawns == [:paris, :epidemic]
    end
    assert [] == PlayerDeck.discard_pile()
  end

	
end