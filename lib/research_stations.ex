defmodule ResearchStation do
  import Logger

  ## Client API

  @doc "Starts the research station management (agent)."
  def start_link(nb_research_stations \\ 6) do
    Agent.start_link(fn -> 
      Logger.debug "Starting with #{nb_research_stations} research stations"
      {nb_research_stations} 
    end, name: :research_stations)
  end

  @doc "Stop the research stations"
  def stop() do
    Agent.stop(:research_stations)
  end

  @doc """
  Return the number of research station that can still be built.
  """
  def nb_research_stations_remaining() do
  	Agent.get(:research_stations, fn {nb_research_stations} ->
      nb_research_stations
    end)
  end

  @doc """
  
  """
  def consume_research_station(listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(:research_stations, fn {nb_research_stations} ->
    	case nb_research_stations do
    		_ when nb_research_stations > 0 ->
          updated = nb_research_stations - 1
          send_if_not_nil listener, {:research_station_consumed, ref, updated}
          {updated}

        _ ->
          updated = 0
          send_if_not_nil listener, {:research_station_consumed, ref, :not_enough_research_station}
          {updated}
    	end

#        case Enum.member? cities, city do
#          true ->
#            send_if_not_nil listener, {:research_station_not_built, ref, city, :already_built}
#            {cities, nb_research_stations}
#
#          _ when nb_research_stations == 0 ->
#            send_if_not_nil listener, {:research_station_not_built, ref, city, :no_more_available}
#            {cities, nb_research_stations}
#
#          _ ->
#            send_if_not_nil listener, {:research_station_built, ref, city, :ok}
#            {[city|cities], nb_research_stations - 1}
#        end
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