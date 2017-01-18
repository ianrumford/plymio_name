ExUnit.start()

defmodule PlymioNameHelpersTest do

  defmacro __using__(_opts \\ []) do

    quote do

      use ExUnit.Case, async: true
      alias Plymio.Name.Utils, as: PNU
    end

  end

end

