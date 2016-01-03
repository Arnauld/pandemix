defmodule InfectionRateMarkerTest do
  use ExUnit.Case
  doctest InfectionRateMarker

  setup do
    {:ok, pid} = InfectionRateMarker.start_link()
    {:ok, pid: pid}
  end

  test "default rates" do
    assert {1, 2} == InfectionRateMarker.current_rate()

    InfectionRateMarker.increase_rate()
    assert {2, 2} == InfectionRateMarker.current_rate()
    
    InfectionRateMarker.increase_rate()
    assert {3, 2} == InfectionRateMarker.current_rate()
    
    InfectionRateMarker.increase_rate()
    assert {4, 3} == InfectionRateMarker.current_rate()
    
    InfectionRateMarker.increase_rate()
    assert {5, 3} == InfectionRateMarker.current_rate()
    
    InfectionRateMarker.increase_rate()
    assert {6, 4} == InfectionRateMarker.current_rate()

    InfectionRateMarker.increase_rate()
    assert {7, 4} == InfectionRateMarker.current_rate()

    InfectionRateMarker.increase_rate()
    assert {8, 4} == InfectionRateMarker.current_rate()

    InfectionRateMarker.increase_rate()
    assert {9, 4} == InfectionRateMarker.current_rate()
  end
end
