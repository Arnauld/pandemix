defmodule DefaultsTest do
  use ExUnit.Case
  doctest Defaults


  test "generate default layout" do
    raw_links = Defaults.default_raw_links()
    city_specs = Defaults.city_specs_from_raw_links(raw_links)
  
    assertSameValues [:london, :algiers, :madrid, :essen, :milan], :paris, city_specs
    assertSameValues [:new_york, :madrid, :paris, :essen], :london, city_specs
    assertSameValues [:miami, :washington, :chicago], :atlanta, city_specs
  end

  defp assertSameValues(values, city, city_specs) do
    assert Enum.sort(values) == Enum.sort(city_specs[city])
  end
end