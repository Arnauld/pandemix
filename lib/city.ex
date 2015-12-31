defmodule City do


  ## Client API

  @doc """
  Starts the city (agent).
  """
  def start_link(city, links \\ []) do
    Agent.start_link(fn -> {city, links, %{}} end, name: city)
  end

  def stop(city) do
    Agent.stop(city)
  end

  @doc """
  """
  def infection_levels(city) do
    Agent.get(city, fn {_name, _links, levels} ->
      Map.to_list(levels)
    end)
  end

  def increase_infection_level(city, disease) do 
    Agent.update(city, fn {name, links, levels} ->
      level = Map.get(levels, disease, 0)
      new_levels = Map.put(levels, disease, level + 1)
      {name, links, new_levels}
    end)
  end
end
