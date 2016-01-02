defmodule CityTest do
  use ExUnit.Case
  doctest City

  setup do
      {:ok, pid} = City.start_link(:london)
      on_exit fn ->
          # We don’t need to explictly shut down the Agent
          # because it will receive a :shutdown signal 
          # when our test finishes. 
          :agent_automatically_stopped
          #City.stop(pid)
    end
    {:ok, pid: pid}
  end

  test "default infection levels" do
    assert [] == City.infection_levels(:london)
  end

  test "increase infection level" do
    City.increase_infection_level(:london, :blue)
    assert [{:blue, 1}] == City.infection_levels(:london)
  end

  test "increase infection level which then trigger an async notification" do
    {:ok, ref} = City.increase_infection_level(:london, :blue, self())
    receive do
        {:infection_level_increased, city, ref0, disease, new_level} ->
            assert 1       == new_level
            assert :blue   == disease
            assert :london == city
            assert ref     == ref0
    end
  end

  test "change infection level" do
    City.change_infection_level(:london, :pink, 4)
    assert [{:pink, 4}] == City.infection_levels(:london)
  end

  test "change infection level which then trigger an async notification" do
    {:ok, ref} = City.change_infection_level(:london, :green, 4, self())
    receive do
        {:infection_level_changed, city, ref0, disease, new_level} ->
            assert 4       == new_level
            assert :green  == disease
            assert :london == city
            assert ref     == ref0
    after
       1_000 -> 
               assert false, "Timeout"
    end
  end

  test "cannot increase infection level above 3" do
    City.change_infection_level(:london, :pink, 3)
    City.increase_infection_level(:london, :pink)
    assert [{:pink, 3}] == City.infection_levels(:london)
  end

  test "cannot increase infection level above 3 which then trigger an async outbreak notification" do
    City.start_link(:paris, [:london, :madrid])
    City.change_infection_level(:paris, :green, 3)
    {:ok, ref} = City.increase_infection_level(:paris, :green, self())
    receive do
        {:infection_level_increased, city, ref0, disease, :outbreak, links} ->
            assert :green == disease
            assert :paris == city
            assert ref    == ref0
            assert [:london, :madrid] == links
    after
       1_000 -> 
               assert false, "Timeout"
    end
  end

  test "retrieve city's links" do
  	City.start_link(:paris, [:london, :madrid])
    assert []                 == City.links(:london)
    assert [:london, :madrid] == City.links(:paris)

  end
end
