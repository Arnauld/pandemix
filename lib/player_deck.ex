defmodule PlayerDeck do
  import Logger
  
  @doc """
  Starts the Player deck (agent).
  """
  def start_link(cards, shuffleFn \\ &Enum.shuffle/1) do
    Agent.start_link(fn -> 
      Logger.debug "Starting Infection deck with #{inspect cards}"
      shuffled = shuffleFn.(cards)
      {shuffled, []} 
    end, name: :player_deck)
  end

  @doc "Stop the Infection deck."
  def stop() do
    Agent.stop(:player_deck)
  end

  @doc "Returns the discard pile of the deck"
  def discard_pile() do
    Agent.get(:player_deck, fn {cards, discard_pile} ->
      discard_pile
    end)
  end

  @doc """
  Draw the `n` first cards from the pile.

  Notification is sent asynchronously once done.
  `{:player_cards_drawn, ref, cards_drawn}`
  """
  def draw(n, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(:player_deck, fn {cards, discard_pile} ->
      drawns = Enum.take cards, n
      remainings = Enum.drop cards, n
      send_if_not_nil listener, {:player_cards_drawn, ref, drawns}
      {remainings, discard_pile}
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