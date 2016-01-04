defmodule InfectionDeckTest do
  use ExUnit.Case
  doctest InfectionDeck

  test "discard pile is empty by default" do
    InfectionDeck.start_link([:paris, :london, :madrid, :algiers, :essen, :new_york])
    assert [] == InfectionDeck.discard_pile()
  end

  test "draw cards" do
    cities = [:paris, :london, :madrid, :algiers, :essen, :new_york]
    InfectionDeck.start_link(cities)

    InfectionDeck.draw(2)

    [one, two] = InfectionDeck.discard_pile()
    assert true        == Enum.member? cities, one
    assert true        == Enum.member? cities, two
  end

  test "draw cards (no shuffle)" do
    cities = [:paris, :london, :madrid, :algiers, :essen, :new_york]
    InfectionDeck.start_link(cities, fn xs -> xs end)

    InfectionDeck.draw(2)
    assert [:paris, :london] = InfectionDeck.discard_pile()

    InfectionDeck.draw(3)
    assert [:madrid, :algiers, :essen, :paris, :london] = InfectionDeck.discard_pile()
  end
    
  test "draw cards which then trigger an async notification" do
    cities = [:paris, :london, :madrid, :algiers, :essen, :new_york]
    InfectionDeck.start_link(cities)
    {:ok, ref} = InfectionDeck.draw(2, self())
    receive do
        {:cards_drawn, ref0, cards_drawn} ->
            assert ref         == ref0
            assert cards_drawn == InfectionDeck.discard_pile()
    end
  end

  test "draw all cards" do
    cities = [:paris, :london, :madrid, :algiers, :essen, :new_york]
    InfectionDeck.start_link(cities)
    {:ok, _ref1} = InfectionDeck.draw(2)
    {:ok, _ref2} = InfectionDeck.draw(3)
    {:ok, _ref3} = InfectionDeck.draw(1)

    assert Enum.sort(cities) == Enum.sort(InfectionDeck.discard_pile())
  end

  test "draw last card (no shuffle)" do
    cities = [:paris, :london, :madrid, :algiers, :essen, :new_york]
    InfectionDeck.start_link(cities, fn xs -> xs end)

    InfectionDeck.draw_last()
    assert [:new_york] = InfectionDeck.discard_pile()

    InfectionDeck.draw(3)
    assert [:paris, :london, :madrid, :new_york] = InfectionDeck.discard_pile()
  end
    
  test "draw last card (no shuffle) which then trigger an async notification" do
    cities = [:paris, :london, :madrid, :algiers, :essen, :new_york]
    InfectionDeck.start_link(cities, fn xs -> xs end)

    {:ok , ref} = InfectionDeck.draw_last(self())
    receive do
        {:last_card_drawn, ref0, card_drawn} ->
            assert ref        == ref0
            assert card_drawn == InfectionDeck.discard_pile()
    end
  end

end