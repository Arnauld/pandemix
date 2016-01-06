defmodule Disease do
  import Logger

  ## Client API

  @doc "Starts the disease (agent)."
  def start_link(disease, nb_cubes \\ 24) do
    Agent.start_link(fn -> 
      Logger.debug "Starting Disease #{disease} with #{nb_cubes} cubes"
      {disease, nb_cubes, :undiscovered} 
    end, name: disease)
  end

  @doc "Stop the disease."
  def stop(disease) do
    Agent.stop(disease)
  end

  def cure_status(disease) do
    Agent.get(disease, fn {_name, _remainings, status} ->
      status
    end)
  end

  @doc """
  
  """
  def mark_cure_discovered(disease, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(disease, fn {name, remainings, status} ->
      send_if_not_nil listener, {:cure_discovered, disease, ref}
      {name, remainings, :discovered}
    end)
    {:ok, ref}
  end

  @doc """
  
  """
  def mark_cure_eradicated(disease, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(disease, fn {name, remainings, status} ->
      send_if_not_nil listener, {:cure_eradicated, disease, ref}
      {name, remainings, :eradicated}
    end)
    {:ok, ref}
  end

  @doc "Return the number of cube remaining for the disease"
  def nb_cubes_remaining(disease) do
    Agent.get(disease, fn {_name, remainings, _status} ->
      remainings
    end)
  end

  @doc """
  Change the number of cube remaining for the disease. 
  Notification is sent asynchronously once done.
  """
  def change_nb_cubes_remaining(disease, nb_cubes, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(disease, fn {name, _remainings, status} ->
      send_if_not_nil listener, {:cube_changed, disease, ref, nb_cubes}
      {name, nb_cubes, status}
    end)
    {:ok, ref}
  end

  @doc """
  Consume disease's cubes.
  Notification is sent asynchronously once done.
  """
  def consume(disease, nb_cubes, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(disease, fn {name, remainings, status} ->
      case remainings do
        _ when remainings >= nb_cubes ->
          updated = remainings - nb_cubes
          send_if_not_nil listener, {:cube_consumed, disease, ref, updated}
          {name, updated, status}

        _ ->
          updated = 0
          send_if_not_nil listener, {:cube_consumed, disease, ref, :not_enough_cubes}
          {name, updated, status}
      end
    end)
    {:ok, ref}
  end

  @doc """
  Release disease's cubes.
  Notification is sent asynchronously once done.
  """
  def release(disease, nb_cubes, listener \\ :nil) do
    ref = :erlang.make_ref()
    Agent.update(disease, fn {name, remainings, status} ->
      updated = remainings + nb_cubes
      send_if_not_nil listener, {:cube_released, disease, ref, updated}
      {name, updated, status}
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