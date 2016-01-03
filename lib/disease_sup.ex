defmodule DiseaseSup do
  use Supervisor

  def start_link(disease_specs \\ [:blue, :red, :yellow, :black]) do
    Supervisor.start_link(__MODULE__, disease_specs)
  end

  def init(disease_specs) do
    children = Enum.map disease_specs, fn (term) -> 
      case term do
        {disease, nb_cubes} ->
          worker(Disease, [disease, nb_cubes], [id: disease])

        disease when is_atom(disease) ->
          worker(Disease, [disease], [id: disease])
      end
    end

    supervise(children, strategy: :one_for_one)
  end
end