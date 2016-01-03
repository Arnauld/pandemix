defmodule DiseaseSupTest do
  use ExUnit.Case
  doctest DiseaseSup

  test "start all four diseases with default" do
    DiseaseSup.start_link()

    assert 24 == Disease.nb_cubes_remaining(:blue)
    assert 24 == Disease.nb_cubes_remaining(:red)
    assert 24 == Disease.nb_cubes_remaining(:yellow)
    assert 24 == Disease.nb_cubes_remaining(:black)
  end

  test "start diseases with custom settings" do
    DiseaseSup.start_link([{:pink, 48}, {:green, 17}, :cyan])

    assert 48 == Disease.nb_cubes_remaining(:pink)
    assert 17 == Disease.nb_cubes_remaining(:green)
    assert 24 == Disease.nb_cubes_remaining(:cyan)
  end
end