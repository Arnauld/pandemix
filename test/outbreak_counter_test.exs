defmodule OutbreakCounterTest do
  use ExUnit.Case
  doctest OutbreakCounter

  setup do
    {:ok, pid} = OutbreakCounter.start_link()
    {:ok, pid: pid}
  end

  test "default outbreak remaining" do
    assert {0, 8} == OutbreakCounter.nb_outbreaks()
  end

  test "declare an outbreak should consume a marker" do
    OutbreakCounter.declare()
    assert {1, 8} == OutbreakCounter.nb_outbreaks()
  end

  test "declare an outbreak should consume a marker which then triggers an async notification " do
    {:ok, ref} = OutbreakCounter.declare(self())
    assert {1, 8} == OutbreakCounter.nb_outbreaks()
    receive do
        {:outbreak_declared, ref0, new_level} ->
            assert 1       == new_level
            assert ref     == ref0
    end
  end

  test "change number of outbreak that occured" do 
    OutbreakCounter.change_nb_outbreaks(4)
    assert {4, 8} == OutbreakCounter.nb_outbreaks()
  end

  test "change number of outbreak that occured which then triggers an async notification" do 
    {:ok, ref} = OutbreakCounter.change_nb_outbreaks(4, self())
    assert {4, 8} == OutbreakCounter.nb_outbreaks()
    receive do
        {:outbreak_changed, ref0, new_level} ->
            assert 4       == new_level
            assert ref     == ref0
    end
  end

  test "cannot declare more outbreak than the threshold" do 
    OutbreakCounter.change_nb_outbreaks(8)
    {:ok, ref} = OutbreakCounter.declare(self())
    assert {8, 8} == OutbreakCounter.nb_outbreaks()
    receive do
        {:outbreak_declared, ref0, new_level} ->
            assert :threshold_reached == new_level
            assert ref                == ref0
    end
  end
end