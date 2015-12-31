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

  test "change infection level" do
  	City.change_infection_level(:london, :pink, 4)
    assert [{:pink, 4}] == City.infection_levels(:london)
  end
end
