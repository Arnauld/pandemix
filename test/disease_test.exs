defmodule DiseaseTest do
  use ExUnit.Case
  doctest Disease

  setup do
      {:ok, pid} = Disease.start_link(:blue)
      on_exit fn ->
          # We don’t need to explictly shut down the Agent
          # because it will receive a :shutdown signal 
          # when our test finishes. 
          :agent_automatically_stopped
          #City.stop(pid)
    end
    {:ok, pid: pid}
  end

  test "default number of cubes remaining" do
    assert 24 == Disease.nb_cubes_remaining(:blue)
  end

  test "consume disease's cubes" do
    Disease.consume :blue, 5
    assert 19 == Disease.nb_cubes_remaining(:blue)
  end

  test "consume disease's cubes which then triggers an async notification " do
    {:ok, ref} = Disease.consume :blue, 5, self()
    assert 19 == Disease.nb_cubes_remaining(:blue)
    receive do
        {:cube_consumed, disease, ref0, new_level} ->
            assert 19      == new_level
            assert :blue   == disease
            assert ref     == ref0
    end
  end

  test "cannot consume more than available disease's cubes" do
    Disease.consume :blue, 34
    assert 0 == Disease.nb_cubes_remaining(:blue)
  end

  test "cannot consume more than available disease's cubes which then triggers an async insufficient notification" do
    {:ok, ref} = Disease.consume :blue, 34, self()
    assert 0 == Disease.nb_cubes_remaining(:blue)
    receive do
        {:cube_consumed, disease, ref0, new_level} ->
            assert :not_enough_cubes == new_level
            assert :blue   == disease
            assert ref     == ref0
    end
  end

  test "release cubes back to available ones" do
    Disease.consume :blue, 14
    Disease.release :blue, 7
    assert 17 == Disease.nb_cubes_remaining(:blue)
  end

  test "release cubes back to available ones which then trigger an async notification" do
    Disease.consume :blue, 14
    {:ok, ref} = Disease.release :blue, 7, self()
    assert 17 == Disease.nb_cubes_remaining(:blue)
    receive do
        {:cube_released, disease, ref0, new_level} ->
            assert 17    == new_level
            assert :blue == disease
            assert ref   == ref0
    end
  end

end