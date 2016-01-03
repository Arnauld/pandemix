defmodule InfectionRateMarker do
  import Logger

  def default_rates(r) when is_integer(r) do
    case r do
      1 -> 2 
      2 -> 2 
      3 -> 2 
      4 -> 3 
      5 -> 3 
      6 -> 4
      7 -> 4
      _ -> 4
    end
  end

  ## Client API

  @doc "Starts the Infection rate marker (agent)."
  def start_link(rates \\ &InfectionRateMarker.default_rates/1) when is_function(rates) do
    Agent.start_link(fn -> 
      Logger.debug "Starting Infection Rate with #{inspect rates} as function"
      {1, rates}
    end, name: :infection_rate)
  end

  @doc "Stop the Infection rate marker."
  def stop() do
    Agent.stop(:infection_rate)
  end

  @doc """
  Return the current infection level and rate.
  `{current_level, current_rate}`
  """
  def current_rate() do
    Agent.get(:infection_rate, fn {current, rates} ->
      {current, rates.(current)}
    end)
  end

  @doc """
  Increase infection level.
  This may change the the infection rate.

  Notification is sent asynchronously once done.
  `{:infection_rate_changed, ref, current_level, current_rate`
  """
  def increase_rate(listener \\ :nil) do
  	ref = :erlang.make_ref()
  	Agent.update(:infection_rate, fn {current, rates} ->
  	  next = current + 1
      send_if_not_nil listener, {:infection_rate_changed, ref, next, rates.(next)}
      {next, rates}
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