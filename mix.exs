defmodule MixScript.Mixfile do
  use Mix.Project

  def project do
    [app: :mix_script,
     name: "MixScript",
     description: description(),
     package: package(),
     docs: [
       extras: ~W(README.md)
     ],
     version: "0.1.0",
     elixir: "~> 1.4",
     escript: [main_module: MixScript],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:credo, "~> 0.4", only: [:dev, :test]},
    ]
  end

  defp description do
    """
    A build utility that allows you to to use mix packages in an elixir script.
    """
  end

  defp package do
    [
      description: description(),
      files: ~w(lib config mix.exs README.md LICENSE),
      maintainers: ["Khaja Minhajuddin"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "http://github.com/minhajuddin/mix_script",
        "Docs"   => "http://hexdocs.pm/mix_script",
      }
    ]
  end
end
