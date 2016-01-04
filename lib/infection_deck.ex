defmodule InfectionDeck do
  import Logger
  
  @doc "Starts the Infection deck (agent)."
  def start_link(cards, shuffleFn \\ &Enum.shuffle/1) do
    Agent.start_link(fn -> 
      Logger.debug "Starting Infection deck with #{inspect cards}"
      shuffled = shuffleFn.(cards)
      {shuffled, []} 
    end, name: :infection_deck)
  end

  @doc "Stop the Infection deck."
  def stop() do
    Agent.stop(:infection_deck)
  end

  @doc "Returns the discard pile of the deck"
  def discard_pile() do
    Agent.get(:infection_deck, fn {cards, discard_pile} ->
      discard_pile
    end)
  end

  @doc """
  Draw the `n` first cards from the pile.
  Cards are moved to the discard pile.
  

  Notification is sent asynchronously once done.
  `{:cards_drawn, ref, cards_drawn}`
  """
  def draw(n, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(:infection_deck, fn {cards, discard_pile} ->
      drawns = Enum.take cards, n
      remainings = Enum.drop cards, n
      send_if_not_nil listener, {:cards_drawn, ref, drawns}
      {remainings, drawns ++ discard_pile}
    end)
    {:ok, ref}
  end


  @doc """
  Draw the last card from the pile.

  Notification is sent asynchronously once done.
  `{:last_card_drawn, ref, card_drawn}`  
  """
  def draw_last(listener \\ :nil) do
  ref = :erlang.make_ref()
    Agent.update(:infection_deck, fn {cards, discard_pile} ->
      drawn = Enum.take cards, -1
      remainings = Enum.drop cards, -1
      send_if_not_nil listener, {:last_card_drawn, ref, drawn}
      {remainings, drawn ++ discard_pile}
    end)
    {:ok, ref}
  end

  defp send_if_not_nil(pid, _msg) when pid==:nil do
    :ok
  end
  defp send_if_not_nil(pid, msg) when is_pid(pid) do
    send pid, msg
  end

end