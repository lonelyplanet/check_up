defmodule CheckUp.Mixfile do
  use Mix.Project

  def project do
    [app: :check_up,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:poison, "~> 4.0"},
      {:plug, "~> 1.8"}
    ]
  end
end
