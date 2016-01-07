defmodule City do
  import Logger

  ## Client API

  @doc "Starts the city (agent)."
  def start_link(city, links \\ []) do
    Agent.start_link(fn -> 
      Logger.debug "Starting City #{city} with links #{inspect links}"
      {city, links, %{}} 
    end, name: city)
  end

  @doc "Stop the city."
  def stop(city) do
    Agent.stop(city)
  end

  @doc "Returns the infection levels of the city"
  def infection_levels(city) do
    Agent.get(city, fn {_name, _links, infection_levels} ->
      Map.to_list(infection_levels)
    end)
  end

  @doc "Returns the links of the city"
  def links(city) do
    Agent.get(city, fn {_name, links, _infection_levels} ->
      links
    end)
  end

  def increase_infection_level(city, disease, listener \\ :nil) do 
    ref = :erlang.make_ref()
    Agent.update(city, fn {name, links, infection_levels} ->
      level = Map.get(infection_levels, disease, 0)
      case level do
        _ when level >= 3 ->
          send_if_not_nil listener, {:infection_level_increased, city, ref, disease, :outbreak, links}
          {name, links, infection_levels}

        _ ->
          new_level = level + 1
          new_levels = Map.put(infection_levels, disease, new_level)
          send_if_not_nil listener, {:infection_level_increased, city, ref, disease, new_level}
          {name, links, new_levels}
      end
    end)
    {:ok, ref}
  end

  def change_infection_level(city, disease, new_level, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(city, fn {name, links, infection_levels} ->
      new_levels = Map.put(infection_levels, disease, new_level)
      send_if_not_nil listener, {:infection_level_changed, city, ref, disease, new_level}
      {name, links, new_levels}
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
