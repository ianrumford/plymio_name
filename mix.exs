defmodule PlymioName.Mixfile do
  use Mix.Project

  @version "0.1.1"

  def project do
    [app: :plymio_name,
     version: @version,
     description: description(),
     package: package(),
     source_url: "https://github.com/ianrumford/plymio_name",
     homepage_url: "https://github.com/ianrumford/plymio_name",
     docs: [extras: ["./README.md", "./CHANGELOG.md"]],
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.15", only: :dev}
    ]
  end

  defp package do
    [maintainers: ["Ian Rumford"],
     files: ["lib", "mix.exs", "README*", "LICENSE*", "CHANGELOG*"],
     licenses: ["MIT"],
     links: %{github: "https://github.com/ianrumford/plymio_name"}]
  end

  defp description do
    """
    plymio_name: Utility Functions for Names
    """
  end

end

