defmodule CitySup do
  use Supervisor

  def start_link(city_specs) do
    Supervisor.start_link(__MODULE__, city_specs)
  end

  def init(city_specs) do
    children = Enum.map city_specs, fn ({city, links}) -> 
      worker(City, [city, links], [id: city])
    end
    supervise(children, strategy: :one_for_one)
  end
end