defmodule Plymio.Name.Attributes do

  @moduledoc false

  defmacro __using__(_opts \\ []) do

    quote do

      @plymio_name_opts_key_transform :transform
      @plymio_name_opts_key_separator :sep
      @plymio_name_opts_key_context :context

    end

  end

end
