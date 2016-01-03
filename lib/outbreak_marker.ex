defmodule OutbreakMarker do
  import Logger

  @default_threshold 8
  ## Client API

  @doc "Starts the outbreak counter (agent)."
  def start_link(outbreak_threshold \\ @default_threshold) do
    Agent.start_link(fn -> 
      Logger.debug "Starting Outbreak counter with #{outbreak_threshold} as threshold"
      {0, outbreak_threshold} 
    end, name: :outbreak_counter)
  end

  @doc "Stop the counter."
  def stop() do
    Agent.stop(:outbreak_counter)
  end

  @doc """
  Return the number of outbreaks that occured.
  `{nb_outbreaks, outbreak_threshold}`
  """
  def nb_outbreaks() do
    Agent.get(:outbreak_counter, fn {nb_outbreaks, outbreak_threshold} ->
      {nb_outbreaks, outbreak_threshold}
    end)
  end

  @doc """
  Change the number of outbreaks that occured. 

  Notification is sent asynchronously once done.
  `{:outbreak_changed, ref, nb_outbreaks}`
  """
  def change_nb_outbreaks(nb_outbreaks, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(:outbreak_counter, fn {_nb_outbreaks, outbreak_threshold} ->
      send_if_not_nil listener, {:outbreak_changed, ref, nb_outbreaks}
      {nb_outbreaks, outbreak_threshold}
    end)
    {:ok, ref}
  end

  @doc """
  Declare an outbreak.

  Notification is sent asynchronously once done.
  `{:outbreak_declared, ref, :threshold_reached}` or `{:outbreak_declared, ref, updated}`
  """
  def declare(listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(:outbreak_counter, fn {nb_outbreaks, outbreak_threshold} ->
      case nb_outbreaks do
        _ when nb_outbreaks < outbreak_threshold ->
          updated = nb_outbreaks + 1
          send_if_not_nil listener, {:outbreak_declared, ref, updated}
          {updated, outbreak_threshold}

        _ ->
          updated = outbreak_threshold
          send_if_not_nil listener, {:outbreak_declared, ref, :threshold_reached}
          {updated, outbreak_threshold}
      end
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