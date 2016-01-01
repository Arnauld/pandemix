defmodule CitySupTest do
  use ExUnit.Case
  doctest CitySup

  test "start cities" do
  	city_specs = [{:london, [:paris, :madrid]}, 
  				  {:madrid, [:london, :paris]},
  				  {:paris,  [:london, :madrid]}]
  	CitySup.start_link(city_specs)

    assert [:paris, :madrid] == City.links(:london)
    assert [:london, :paris] == City.links(:madrid)
    assert [:london, :madrid] == City.links(:paris)
  end

end