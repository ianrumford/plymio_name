defmodule Plymio.Name.Utils do

  @moduledoc ~S"""
  Utility functions for `names`

  An element of a `name` is anything `Kernel.to_string/1` can transform to a string.
  """

  @typedoc "A name element"
  @type namel :: nil | :atom | :number | String.t

  @typedoc "A name"
  @type name :: namel | [namel]

  @typedoc "Option"
  @type option ::
  {:transform, fun | [fun]} |
  {:sep, name}

  @typedoc "Options"
  @type options :: [option]

  use Plymio.Name.Attributes

  defp separator_to_string(sep) when is_binary(sep), do: sep
  defp separator_to_string(sep), do: name_to_string(sep)

  # header
  @doc ~S"""
  Transforms a `name` to a `String`.

  Use the `:sep` option to separate each element of the `name`.

  Apply the `:transform` function(s) (if given) to the created string.

  ## Examples

      iex> name_to_string(:abc)
      "abc"

      iex> name_to_string([:a, "b", :c], sep: "_")
      "a_b_c"

      iex> name_to_string([:a, "b", :c], sep: "/", transform: &String.capitalize/1)
      "A/b/c"

      iex> name_to_string([:a, 1, ["b", nil, 2], [nil, :c, 3]],
      ...>   transform: [&String.capitalize/1, fn str -> str <> "FortyTwo" end])
      "A1b2c3FortyTwo"

  """

  @spec name_to_string(name, options) :: String.t
  def name_to_string(name, opts \\ nil)

  def name_to_string(name, nil) when is_binary(name), do: name
  def name_to_string(name, nil) when is_nil(name), do: ""
  def name_to_string(name, nil) when is_atom(name), do: name |> to_string
  def name_to_string(name, nil) when is_number(name), do: name |> to_string
  def name_to_string(name, nil) when is_list(name) do
    name |> Enum.map(&name_to_string/1) |> Enum.join
  end

  def name_to_string(name, opts) when is_tuple(name) do
    name |> Tuple.to_list |> name_to_string(opts)
  end

  def name_to_string(name, opts) when is_list(opts) do

    name =
      case is_list(name) do

        true ->

          # don't propagate the transform(s)
          opts_namel = opts |> Keyword.drop([@plymio_name_opts_key_transform])

          name = name |> Enum.map(fn v -> name_to_string(v, opts_namel) end)

          case Keyword.get(opts, @plymio_name_opts_key_separator) do
            x when x != nil -> Enum.join(name, separator_to_string(x))
            _ -> Enum.join(name)
          end

        _ -> name_to_string(name)

      end

    # any transform function?
    case Keyword.get(opts, @plymio_name_opts_key_transform) do
      fun when fun != nil ->

        case fun do
          x when is_function(x) -> x.(name)
          x when is_list(x) -> x |> Enum.reduce(name, fn f, s -> f.(s) end)
        end

      _ -> name
    end

  end

  @doc ~S"""
  Transforms a list of names to a list of strings.

  ## Examples

      iex> names_to_strings([:aBc, 123, "xYz"])
      ["aBc", "123", "xYz"]

      iex> names_to_strings([:aBc, 123, "xYz"], transform: &String.capitalize/1)
      ["Abc", "123", "Xyz"]

  """
  @spec names_to_strings([name], options) :: [String.t]
  def names_to_strings(names, opts \\ []) when is_list(names) do
    names
    |> Stream.reject(&is_nil/1)
    |> Stream.map(fn name -> name_to_string(name, opts) end)
    |> Enum.reject(&is_nil/1)
  end

  @doc ~S"""
  Transforms a `name` to a `Atom`.

  Create an intermediate string first using `name_to_string/2` and then transforms the result to an atom.

  ## Examples

      iex> name_to_atom(:abc)
      :abc

      iex> name_to_atom([:a, "b", :c], sep: "_")
      :"a_b_c"

      iex> name_to_atom([:a, "b", :c], sep: "/", transform: &String.capitalize/1)
      :"A/b/c"

      iex> name_to_atom([:a, 1, ["b", nil, 2], [nil, :c, 3]], transform: &String.capitalize/1)
      :A1b2c3

  """

  @spec name_to_atom(name, options) :: atom
  def name_to_atom(name, opts \\ [])

  def name_to_atom(name, opts) do
    case name_to_string(name, opts) do
      x when is_atom(x) -> x
      x when is_binary(x) -> x |> String.to_atom
    end
  end

  @doc ~S"""
  Transforms a list of names to a list of atoms.

  ## Examples

      iex> names_to_atoms([:abc, 123, "xyz"])
      [:abc, :"123", :xyz]
  """
  @spec names_to_atoms([name], options) :: [atom]
  def names_to_atoms(name, opts \\ []) when is_list(name) do
    name
    |> Stream.reject(&is_nil/1)
    |> Stream.map(fn name -> name_to_atom(name, opts) end)
    |> Enum.reject(&is_nil/1)
  end

  @doc ~S"""
  Transforms a `name` to a Macro.var.

  Create an intermediate atom first using `name_to_atom/2` and then
  creates the ast for the var using `Macro.var/2`.

  The `:context` option (if any; default `nil`) is passed to `Macro.var/2`.

  ## Examples

      iex> name_to_var(:abc)
      {:abc, [], nil}

      iex> name_to_var([:a, "b", :c], sep: "_")
      {:"a_b_c", [], nil}

      iex> name_to_var([:a, "b", :c], sep: "_", context: ModuleA)
      {:"a_b_c", [], ModuleA}

  """
  @spec name_to_var(name, options) :: {var, [], context} when var: atom, context: atom

  def name_to_var(name, opts \\ []) do
    name
    |> name_to_atom(opts)
    |> Macro.var(opts |> Keyword.get(@plymio_name_opts_key_context))
  end

  @doc ~S"""
  Transforms a list of names to a list of vars.

  ## Examples

      iex> names_to_vars([:abc, 123, "xyz"])
      [{:abc, [], nil}, {:"123", [], nil}, {:xyz, [], nil}]

      iex> names_to_vars([:AbC, 123, "XyZ"], transform: &String.downcase/1)
      [{:abc, [], nil}, {:"123", [], nil}, {:xyz, [], nil}]

  """
  @spec names_to_vars([name], options) :: [{var, [], context}] when var: atom, context: atom
  def names_to_vars(names, opts \\ []) when is_list(names) do
    names
    |> Stream.map(fn name -> name_to_var(name, opts) end)
    |> Enum.reject(&is_nil/1)
  end

  @doc ~S"""
  Transforms the name to a string and capitalize the first character
  of a name and leave rest alone (i.e. does *not* lowercase rest).

  ## Examples

      iex> name_capitalize_first(:abc)
      "Abc"

      iex> name_capitalize_first("abcDeF")
      "AbcDeF"

  """
  @spec name_capitalize_first(name) :: String.t
  def name_capitalize_first(name) when is_binary(name) do

    # split on first char
    splits = String.split_at(name, 1)

    # capitalize the first char and concat with rest
    String.capitalize(elem(splits, 0)) <> elem(splits, 1)

  end

  def name_capitalize_first(name) do
    name
    |> name_to_string
    |> name_capitalize_first
  end

  @doc ~S"""
  Splits a string on underscore and concats the splits
  after capitalizing *only* the first character of each split.

  ## Examples

      iex> name_camel_case("hello_world")
      "HelloWorld"

      iex> name_camel_case("HellO_worLd")
      "HellOWorLd"

      iex> name_camel_case("heLLoworld")
      "HeLLoworld"
  """

  @spec name_camel_case(name) :: String.t
  def name_camel_case(name) when is_binary(name) do
    name
    |> String.split("_")
    |> Stream.map(&name_capitalize_first/1)
    |> Enum.join
  end

  def name_camel_case(name) do
    name
    |> name_to_string
    |> name_camel_case
  end

  @doc ~S"""
  Creates a unique string from a reference.

  Uses `Kernel.make_ref/0` to generate the unique value (e.g.
  *#Reference<0.0.2.293>*), transforms to a string, extracts
  everthing betwen the "<" and ">" and replaces dots with underscores.

  ## Examples

      name_uniqueness() # e.g. "0_0_2_293"
  """
  @spec name_uniqueness() :: String.t
  def name_uniqueness() do
    make_ref()
    |> inspect
    |> String.slice(11..-2)
    |> String.replace(".", "_")
  end

  @doc ~S"""
  Creates a unique string using `name_uniqueness/0` and appends to the
  name (default "uniq").

  ## Examples

      iex> << x :: bytes-size(4), _rest :: binary >> = name_to_string_unique()
      ...> match?("uniq", x)
      true

      iex> << x :: bytes-size(3), _rest :: binary >> = name_to_string_unique(:abc)
      ...> match?("abc", x)
      true

      iex> << x :: bytes-size(6), _rest :: binary >> = name_to_string_unique(:aBcDeF, transform: &String.capitalize/1)
      ...> match?("Abcdef", x)
      true
  """
  @spec name_to_string_unique(name, options) :: String.t
  def name_to_string_unique(name \\ "uniq", opts \\ [])

  def name_to_string_unique(name, opts) do
    name_to_string([name, name_uniqueness()], opts)
  end

  @doc ~S"""
  Creates a unique string using `name_uniqueness/0` and appends to the
  name (default "uniq"), and transforms the string to an atom.

  ## Examples

      iex> atom = name_to_atom_unique(:aBcDeF, transform: &String.capitalize/1) # e.g. :"Abcdef0_0_2_293"
      ...> << x :: bytes-size(6), _rest :: binary >> = atom |> to_string
      ...> match?("Abcdef", x)
      true

  """
  @spec name_to_atom_unique(name) :: atom

  def name_to_atom_unique(name, opts \\ []) do
    name_to_atom([name, name_uniqueness()], opts)
  end

  @doc ~S"""
  Creates a string from the `Kernel.self/0` pid using inspect, extracts
  everything between the "<" and ">", and replaces the dots with
  underscores.

  ## Examples

      iex> << x :: bytes-size(2), _rest :: binary >> = name_self() # e.g. "0_789_0"
      ...> match?("0_", x)
      true

      iex> << x :: bytes-size(12), _rest :: binary >> = name_self(:"my_pid_is_") # e.g. "my_pid_is_0_80_0"
      ...> match?("my_pid_is_0_", x)
      true
  """

  @spec name_self(name) :: String.t

  def name_self(name \\ nil)

  def name_self(nil) do
    self()
    |> inspect
    |> String.slice(5..-2)
    |> String.replace(".", "_")
  end

  def name_self(name) do
    name_to_string(name) <> name_self()
  end

end

