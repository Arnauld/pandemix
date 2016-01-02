defmodule InfestorTest do
  use ExUnit.Case, async: false
  doctest Infestor

  test "simple infection" do
    city_specs = [{:london, [:paris, :madrid]}, 
                  {:madrid, [:london, :paris]},
                  {:paris,  [:london, :madrid]}]
    CitySup.start_link(city_specs)

    City.change_infection_level(:london, :blue, 2)
    City.change_infection_level(:madrid, :blue, 1)

    {:ok, journal} = Infestor.infect(:london, :blue)
    assert [{:propagate, :london}, 
            {:infected, :london, 3}] == journal

    assert [{:blue, 3}] == City.infection_levels(:london)
    assert [{:blue, 1}] == City.infection_levels(:madrid)
    assert [] == City.infection_levels(:paris)
  end

  test "outbreak propagation" do
    city_specs = [{:london, [:paris, :madrid]}, 
            {:madrid, [:london, :paris]},
            {:paris,  [:london, :madrid]}]
    CitySup.start_link(city_specs)

    City.change_infection_level(:london, :blue, 3)
    City.change_infection_level(:madrid, :blue, 1)

    {:ok, journal} = Infestor.infect(:london, :blue)
    assert [{:propagate, :london}, 
            {:outbreak, :london}, 
            {:propagate, :paris}, 
            {:propagate, :madrid}, 
            {:infected, :paris, 1},
            {:infected, :madrid, 2}] == journal

    assert [{:blue, 3}] == City.infection_levels(:london)
    assert [{:blue, 2}] == City.infection_levels(:madrid)
    assert [{:blue, 1}] == City.infection_levels(:paris)
  end

  test "chain outbreak propagation" do
    city_specs = [{:london, [:paris, :madrid]}, 
                  {:madrid, [:london, :paris]},
                  {:paris,  [:london, :madrid]}]
    CitySup.start_link(city_specs)

    City.change_infection_level(:london, :blue, 3)
    City.change_infection_level(:madrid, :blue, 3)
    City.change_infection_level(:paris,  :blue, 2)

    {:ok, journal} = Infestor.infect(:london, :blue)
    assert [{:propagate, :london}, 
            {:outbreak, :london}, 
            {:propagate, :paris}, 
            {:propagate, :madrid}, 
            {:infected, :paris, 3},
            {:outbreak, :madrid}, 
            {:propagate, :paris}, 
            {:outbreak, :paris}] == journal

    assert [{:blue, 3}] == City.infection_levels(:london)
    assert [{:blue, 3}] == City.infection_levels(:madrid)
    assert [{:blue, 3}] == City.infection_levels(:paris)
  end
end