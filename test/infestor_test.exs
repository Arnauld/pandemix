defmodule InfestorTest do
  use ExUnit.Case, async: false
  doctest Infestor

  setup do
	Disease.start_link :blue
	city_specs = [{:london, [:paris,  :madrid]}, 
                  {:madrid, [:london, :paris]},
                  {:paris,  [:london, :madrid]}]
    CitySup.start_link(city_specs)
    :ok
  end

  test "simple infection" do
  	#
  	# Given
  	#
    City.change_infection_level(:london, :blue, 2)
    City.change_infection_level(:madrid, :blue, 1)

    #
    # When
    #
    {:ok, journal} = Infestor.infect(:london, :blue)

    #
    # Then
    #
    assert [{:consuming_cube, :london},
            {:propagate, :london}, 
            {:infected, :london, 3}] == journal
    assert [{:blue, 3}] == City.infection_levels(:london)
    assert [{:blue, 1}] == City.infection_levels(:madrid)
    assert [] == City.infection_levels(:paris)
  end

  test "simple infection failure when not enough cubes" do
  	City.change_infection_level(:london, :blue, 2)
    Disease.change_nb_cubes_remaining(:blue, 0)

    {:error, reason} = Infestor.infect(:london, :blue)

    assert :not_enough_cubes == reason[:what]
    assert [consuming_cube: :london] == reason[:journal]
  end

  test "outbreak propagation" do
    City.change_infection_level(:london, :blue, 3)
    City.change_infection_level(:madrid, :blue, 1)

    {:ok, journal} = Infestor.infect(:london, :blue)

    assert [{:consuming_cube, :london}, 
            {:propagate, :london}, 
            {:outbreak, :london}, 
            {:consuming_cube, :paris}, 
            {:consuming_cube, :madrid},
            {:propagate, :paris}, 
            {:propagate, :madrid}, 
            {:infected, :paris, 1}, 
            {:infected, :madrid, 2}] == journal
    assert [{:blue, 3}] == City.infection_levels(:london)
    assert [{:blue, 2}] == City.infection_levels(:madrid)
    assert [{:blue, 1}] == City.infection_levels(:paris)
  end

  test "chain outbreak propagation" do
    City.change_infection_level(:london, :blue, 3)
    City.change_infection_level(:madrid, :blue, 3)
    City.change_infection_level(:paris,  :blue, 2)

    {:ok, journal} = Infestor.infect(:london, :blue)

    assert [{:consuming_cube, :london}, 
            {:propagate, :london}, 
            {:outbreak, :london}, 
            {:consuming_cube, :paris}, 
            {:consuming_cube, :madrid},
            {:propagate, :paris}, 
            {:propagate, :madrid}, 
            {:infected, :paris, 3}, 
            {:outbreak, :madrid}, 
            {:consuming_cube, :paris},
            {:propagate, :paris}, 
            {:outbreak, :paris}] == journal
    assert [{:blue, 3}] == City.infection_levels(:london)
    assert [{:blue, 3}] == City.infection_levels(:madrid)
    assert [{:blue, 3}] == City.infection_levels(:paris)
  end
end