defmodule Infestor do
  require Logger

  @timeout_overall      5000
  @timeout_notification 1000

  @doc "Infect the city."
  def infect(city, disease) do
    listener = self()
    to_infect = [city]
    already_outbreaked = MapSet.new()
    pending = []
    journal = []
    ref = :erlang.make_ref()
    spawn_link Infestor, :propagate, [ref, listener, disease, to_infect, already_outbreaked, pending, journal]
    receive do
      {:ok, ref0, updated_journal} when ref0 == ref ->
        {:ok, Enum.reverse(updated_journal)}

      {:error, reason} ->
        {:error, reason}

      other ->
        Logger.warn "infect, received a unrecognized_message #{inspect other}"
    after
      @timeout_overall ->
        :timeout
    end
  end

  def propagate(ref, listener, _disease, [], _already_outbreaked, [], journal) do
    send listener, {:ok, ref, journal}
  end

  def propagate(ref, listener, disease, [to_infect|others_to_infect], already_outbreaked, pending, journal) do
    case MapSet.member?(already_outbreaked, to_infect) do
      true ->
        propagate(ref, listener, disease, others_to_infect, already_outbreaked, pending, journal)

      false ->
        {ok, infect_ref} = City.increase_infection_level to_infect, disease, self()
        new_journal = [{:propagate, to_infect} | journal]
        new_pending = [{infect_ref, to_infect} | pending]
        propagate(ref, listener, disease, others_to_infect, already_outbreaked, new_pending, new_journal)
    end
  end

  def propagate(ref, listener, disease, [], already_outbreaked, pending, journal) do
    Logger.debug "propagate.3, pending #{inspect pending}"
    receive do
      {:infection_level_increased, city, ref0, disease, :outbreak, links} ->
        outbreaked = MapSet.put already_outbreaked, city
        new_journal = [{:outbreak, city} | journal]
        new_pending = List.delete pending, {ref0, city}
          propagate(ref, listener, disease, links, outbreaked, new_pending, new_journal)

      {:infection_level_increased, city, ref0, disease, new_level} ->
        new_journal = [{:infected, city, new_level} | journal]
        new_pending = List.delete pending, {ref0, city}
          propagate(ref, listener, disease, [], already_outbreaked, new_pending, new_journal)

      other ->
        Logger.warn "propagate.3, unrecognized_message: #{inspect other}"
        new_journal = [{:unrecognized_message, other} | journal]
          propagate(ref, listener, disease, [], already_outbreaked, pending, new_journal)

    after 
      @timeout_notification ->
        send listener, {:error, {:timeout, {:pending, pending}}}
    end
  end

end