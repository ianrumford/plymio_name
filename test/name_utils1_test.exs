defmodule PlymioNameUtils1Test do

  use PlymioNameHelpersTest

  test "name_to_string: scalar" do
    assert PNU.name_to_string("x") == "x"
    assert PNU.name_to_string(42) == "42"
    assert PNU.name_to_string(:myatom1) == "myatom1"
  end

  test "name_to_string: list of one scalar" do
    assert PNU.name_to_string(["x"]) == "x"
    assert PNU.name_to_string([42]) == "42"
    assert PNU.name_to_string([:myatom1]) == "myatom1"
    assert PNU.name_to_string({:t1, "t2", 3}) == "t1t23"
  end

  test "name_to_string: list of n scalars" do
    assert PNU.name_to_string(["x", "y", "z"]) == "xyz"
    assert PNU.name_to_string([42, 43, 44]) == "424344"
    assert PNU.name_to_string([:myatom1]) == "myatom1"
    assert PNU.name_to_string([{:t1, "t2", 3}]) == "t1t23"
    catch_error(PNU.name_to_string(42, 43, 44))
  end

  test "name_to_string: list of list & scalars" do
    assert PNU.name_to_string(["x", ["y", "z"]]) == "xyz"
    assert PNU.name_to_string([[42], 43, 44]) == "424344"
    assert PNU.name_to_string([:myatom1, [:myatom2, [:myatom3]]]) == "myatom1myatom2myatom3"
  end

  test "name_to_string: sep - not used for scalars" do

    assert PNU.name_to_string("x", sep: :Q) == "x"
    assert PNU.name_to_string(42, sep: 9) == "42"
    assert PNU.name_to_string(:myatom1, sep: "SEP") == "myatom1"

    assert PNU.name_to_string({:t1, "t2", 3} , sep: "SEP") == "t1SEPt2SEP3"
    assert PNU.name_to_string([:l1, "l2", 3] , sep: "SEP") == "l1SEPl2SEP3"

  end

  test "name_to_string: lists; sep" do

    assert PNU.name_to_string(["x", "y", "z"], sep: :Q) == "xQyQz"
    assert PNU.name_to_string([42, :fortythree, "fortyfour"], sep: 9) == "429fortythree9fortyfour"

    assert PNU.name_to_string({:myatom1, :is, "sep"}, sep: "SEP") == "myatom1SEPisSEPsep"
    assert PNU.name_to_string([:myatom1, :is, "sep"], sep: "SEP") == "myatom1SEPisSEPsep"

    assert PNU.name_to_string([{:t1, "t2", 3}, :myatom1, :is, "sep"], sep: "SEP") == "t1SEPt2SEP3SEPmyatom1SEPisSEPsep"

  end

  test "name_to_string: with transform" do

    assert PNU.name_to_string(["x", "y", "z"], sep: :Q, transform: fn x -> x |> String.to_atom end) == :xQyQz

    assert PNU.name_to_string([42, :fortythree, "fortyfour"] , sep: 9,  transform: fn x -> x |> String.to_atom end) == :'429fortythree9fortyfour'

    assert PNU.name_to_string([:myatom1, :is, "sep"], sep: "SEP",  transform: fn x -> x |> String.to_atom end) == :myatom1SEPisSEPsep

    assert PNU.name_to_string([:myatom1, :is, "sep"], sep: "SEP",  transform: fn x -> x |> String.capitalize end) == "Myatom1sepissepsep"

    assert PNU.name_to_string([:myatom1, :is, "sep"],  transform: fn x -> x |> String.capitalize end) == "Myatom1issep"

  end

  test "names_to_strings" do

    assert PNU.names_to_strings(["x", "y", "z"]) == ["x", "y", "z"]
    assert PNU.names_to_strings([:xyz, ABC, 123]) == ["xyz", "Elixir.ABC", "123"]

  end

  test "names_to_strings: with transform" do

    transform1 = fn str -> str <> str end

    assert PNU.names_to_strings(["x", "y", "z"], transform: transform1) == ["xx", "yy", "zz"]

    transform2 = &String.capitalize/1

    assert PNU.names_to_strings(["x", "y", "z"],  transform: transform2) == ["X", "Y", "Z"]

  end

  test "name_camel_case" do
    assert PNU.name_camel_case("Abc") == "Abc"
    assert PNU.name_camel_case("A_bc") == "ABc"
    assert PNU.name_camel_case(:x_y_z) == "XYZ"
    assert PNU.name_camel_case(:xxx_yyy_zzz) == "XxxYyyZzz"
    assert PNU.name_camel_case(1) == "1"
    assert PNU.name_camel_case(123) == "123"
  end

  test "name_capitalize_first" do
    assert PNU.name_capitalize_first(:a) == "A"
    assert PNU.name_capitalize_first(:abc) == "Abc"
    assert PNU.name_capitalize_first("Abc") == "Abc"
    assert PNU.name_capitalize_first("aBC") == "ABC"
    assert PNU.name_capitalize_first(1) == "1"
    assert PNU.name_capitalize_first(123) == "123"
  end

  test "name_self" do
    assert << "a", "0_", _rest :: binary >> = PNU.name_self(:a)
    assert << "AbCdEf", "0_", _rest :: binary >> = PNU.name_self("AbCdEf")
  end

  test "name_to_atom: scalar" do
    assert PNU.name_to_atom("x") == :x
    assert PNU.name_to_atom(42) == :"42"
    assert PNU.name_to_atom(:myatom1) == :myatom1
  end

  test "name_to_atom: list of one scalar" do
    assert PNU.name_to_atom(["x"]) == :x
    assert PNU.name_to_atom([42]) == :"42"
    assert PNU.name_to_atom([:myatom1]) == :myatom1
    assert PNU.name_to_atom({:t1, "t2", 3}) == :t1t23
  end

  test "name_to_atom: list of n scalars" do
    assert PNU.name_to_atom(["x", "y", "z"]) == :xyz
    assert PNU.name_to_atom([42, 43, 44]) == :"424344"
    assert PNU.name_to_atom([:myatom, 1]) == :myatom1
    assert PNU.name_to_atom([{:t1, "t2", 3}]) == :t1t23
    catch_error(PNU.name_to_atom(42, 43, 44))
  end

  test "name_to_atom: list of list & scalars" do
    assert PNU.name_to_atom(["x", ["y", "z"]]) == :xyz
    assert PNU.name_to_atom([[42], 43, 44]) == :"424344"
    assert PNU.name_to_atom([:myatom1, [:myatom2, [:myatom3]]]) == :myatom1myatom2myatom3
  end

  test "name_to_atom: sep - not used for scalars" do

    assert PNU.name_to_atom("x", sep: :Q) == :x
    assert PNU.name_to_atom(42, sep: 9) == :"42"
    assert PNU.name_to_atom(:myatom1, sep: "SEP") == :myatom1

    assert PNU.name_to_atom({:t1, "t2", 3} , sep: "SEP") == :t1SEPt2SEP3
    assert PNU.name_to_atom([:l1, "l2", 3] , sep: "SEP") == :l1SEPl2SEP3

  end

  test "name_to_atom: lists; sep" do

    assert PNU.name_to_atom(["x", "y", "z"], sep: :Q) == :xQyQz
    assert PNU.name_to_atom([42, :fortythree, "fortyfour"], sep: 9) == :"429fortythree9fortyfour"

    assert PNU.name_to_atom({:myatom1, :is, "sep"}, sep: "SEP") == :myatom1SEPisSEPsep
    assert PNU.name_to_atom([:myatom1, :is, "sep"], sep: "SEP") == :myatom1SEPisSEPsep

    assert PNU.name_to_atom([{:t1, "t2", 3}, :myatom1, :is, "sep"], sep: "SEP") == :t1SEPt2SEP3SEPmyatom1SEPisSEPsep

  end

  test "name_to_atom: with transform" do

    assert PNU.name_to_atom(["x", "y", "z"], sep: :Q, transform: fn x -> x |> String.to_atom end) == :xQyQz

    assert PNU.name_to_atom([42, :fortythree, "fortyfour"] , sep: 9,  transform: fn x -> x |> String.to_atom end) == :'429fortythree9fortyfour'

    assert PNU.name_to_atom([:myatom1, :is, "sep"], sep: "SEP",  transform: fn x -> x |> String.to_atom end) == :myatom1SEPisSEPsep

    assert PNU.name_to_atom([:myatom1, :is, "sep"], sep: "SEP",  transform: fn x -> x |> String.capitalize end) == :"Myatom1sepissepsep"

    assert PNU.name_to_atom([:myatom1, :is, "sep"],  transform: fn x -> x |> String.capitalize end) == :"Myatom1issep"

  end

  test "names_to_atoms" do

    assert PNU.names_to_atoms(["x", "y", "z"]) == [:x, :y, :z]

    assert PNU.names_to_atoms(["x", "y", "z"],  transform: fn x -> x |> String.capitalize end) == [:X, :Y, :Z]

  end

end
