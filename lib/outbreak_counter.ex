defmodule OutbreakCounter do
  import Logger

  ## Client API

  @doc "Starts the outbreak counter (agent)."
  def start_link(nb_max_outbreak \\ 8) do
    Agent.start_link(fn -> 
      Logger.debug "Starting Outbreak counter with #{nb_max_outbreak} as threshold"
      {0, nb_max_outbreak} 
    end, name: :outbreak_counter)
  end

  @doc "Stop the counter."
  def stop() do
    Agent.stop(:outbreak_counter)
  end

  @doc "Return the number of outbreaks that occured"
  def nb_outbreaks() do
    Agent.get(:outbreak_counter, fn {nb_outbreaks, nb_max_outbreak} ->
      {nb_outbreaks, nb_max_outbreak}
    end)
  end

  @doc """
  Change the number of outbreaks that occured. 
  Notification is sent asynchronously once done.
  """
  def change_nb_outbreaks(nb_outbreaks, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(:outbreak_counter, fn {_nb_outbreaks, nb_max_outbreak} ->
      send_if_not_nil listener, {:outbreak_changed, ref, nb_outbreaks}
      {nb_outbreaks, nb_max_outbreak}
    end)
    {:ok, ref}
  end

  @doc """
  Declare an outbreak.
  Notification is sent asynchronously once done.
  """
  def declare(listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(:outbreak_counter, fn {nb_outbreaks, nb_max_outbreak} ->
      case nb_outbreaks do
        _ when nb_outbreaks < nb_max_outbreak ->
          updated = nb_outbreaks + 1
          send_if_not_nil listener, {:outbreak_declared, ref, updated}
          {updated, nb_max_outbreak}

        _ ->
          updated = nb_max_outbreak
          send_if_not_nil listener, {:outbreak_declared, ref, :threshold_reached}
          {updated, nb_max_outbreak}
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