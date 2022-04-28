defmodule MavenCleaner.MixProject do
  use Mix.Project

  def project do
    [
      app: :maven_cleaner,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [
        main_module: MavenCleaner.CLI,
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :xmerl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      {:filetree2, git: "https://github.com/grmble/filetree2.git", tag: "3e3a6fb"},
    ]
  end
end
