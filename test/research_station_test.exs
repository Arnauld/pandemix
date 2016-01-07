defmodule ResearchStationTest do
  use ExUnit.Case
  doctest ResearchStation

  test "default number of research station remaining" do
    ResearchStation.start_link()
    assert 6 == ResearchStation.nb_research_stations_remaining()
  end


  test "consume research station's building" do
    ResearchStation.start_link()
    ResearchStation.consume_research_station()
    assert 5 == ResearchStation.nb_research_stations_remaining()
  end

  test "consume research station's building which then triggers an async notification " do
    ResearchStation.start_link()
    {:ok, ref} = ResearchStation.consume_research_station(self())
    assert 5 == ResearchStation.nb_research_stations_remaining()
    receive do
        {:research_station_consumed, ref0, remaining} ->
            assert 5   == remaining
            assert ref == ref0
    end
  end
end