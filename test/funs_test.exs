defmodule FunsTest do
  use ExUnit.Case
  doctest InfectionDeck

  test "distribute xs elems into n lists - balanced chunks" do
    xs = [:a1, :a2, :a3, :a4, :a5, :a6, :a7, :a8, :a9, :a10, :a11, :a12]
    [l1, l2, l3] = Funs.distribute xs, 3
    assert [:a1, :a2,  :a3,  :a4 ] == l3
    assert [:a5, :a6,  :a7,  :a8 ] == l2
    assert [:a9, :a10, :a11, :a12] == l1
  end
  
  test "distribute xs elems into n lists - unbalanced chunks" do
    xs = [:a1, :a2, :a3, :a4, :a5, :a6, :a7, :a8, :a9, :a10, :a11, :a12, :a13, :a14]
    [l1, l2, l3] = Funs.distribute xs, 3
    assert [:a1,  :a2,  :a3,  :a4, :a5 ] == l3
    assert [:a6,  :a7,  :a8,  :a9, :a10] == l2
    assert [:a11, :a12, :a13, :a14]      == l1
  end
  
  test "distribute xs elems into n lists - not enough elements" do
    xs = [:a1, :a2]
    [l1, l2, l3] = Funs.distribute xs, 3
    assert [:a1] == l3
    assert [:a2] == l2
    assert []    == l1
  end

end