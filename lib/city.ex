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

  def increase_infection_level(city, disease, originator \\ :nil) do 
    ref = :erlang.make_ref()
    Agent.update(city, fn {name, links, levels} ->
      level = Map.get(levels, disease, 0)
      case level do
        _ when level >= 3 ->
          send_if_not_nil originator, {:infection_level_increased, city, ref, disease, :outbreak}
          {name, links, levels}
        _ ->
          new_level = level + 1
          new_levels = Map.put(levels, disease, new_level)
          send_if_not_nil originator, {:infection_level_increased, city, ref, disease, new_level}
          {name, links, new_levels}
      end
    end)
    {:ok, ref}
  end

  def change_infection_level(city, disease, new_level) do
    Agent.update(city, fn {name, links, levels} ->
      new_levels = Map.put(levels, disease, new_level)
      {name, links, new_levels}
    end)
  end

  defp send_if_not_nil(pid, msg) do
    case pid do
      :nil ->
        :ok
      _    ->
        send pid, msg
    end
  end
end
