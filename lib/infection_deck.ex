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
  Draw `n` cards from the cards pile to the discard pile.
  The cards drawn are return.
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

  defp send_if_not_nil(pid, _msg) when pid==:nil do
    :ok
  end
  defp send_if_not_nil(pid, msg) when is_pid(pid) do
    send pid, msg
  end

end