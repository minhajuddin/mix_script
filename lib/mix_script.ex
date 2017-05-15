defmodule MixScript do
  @moduledoc false
  import Logger, only: [info: 1]

  def main(["compile", mix_script_filepath]) do
    with {mix_deps, mix_script} <- parse_script(mix_script_filepath),
      {:ok, tmp_dir} <- create_tmp_dir([mix_deps, mix_script]),
      :ok <- create_mix_project(mix_deps, mix_script, tmp_dir),
      target_file = mix_script_filepath |> Path.absname |> Path.rootname,
      :ok <- compile_mix_project(tmp_dir, target_file),
      File.rm_rf!(tmp_dir) do
        IO.puts("compiled mix_script")
    else
      err ->
        IO.puts("An error occured:")
        IO.puts(inspect err)
    end
  end

  def main(_) do
    IO.puts """
    Invalid args

    \tUsage
    \tmix_script compile path-to-your-mixscript.exs
    """
  end

  defp create_mix_project(mix_deps, mix_script, tmp_dir) do
    # generate mix project
    exec "mix", ["new", tmp_dir, "--module", "MixScript", "--app", "mix_script"]
    # change mix.exs
    # set deps
    info "replacing deps"
    mix_exs_path = Path.join(tmp_dir, "mix.exs")
    mix_exs_path
    |> File.stream!
    |> Enum.to_list
    |> Enum.reduce({"", []}, fn line, {prev_line, acc} ->
      line_to_be_appended =
        cond do
          String.contains?(prev_line, "defp deps do") -> mix_deps
          Regex.match?(~r[^\s*elixir: ".*",\s*$],prev_line) -> "escript: [main_module: MixScript],\n"
          true -> line
        end

      {line, [line_to_be_appended | acc]}
    end)
    |> elem(1)
    |> Enum.reverse
    |> Enum.into(File.stream!(mix_exs_path))
    info "setting up escript"
    # set escript
    Path.join([tmp_dir, "lib", "mix_script.ex"])
    |> File.write!(mix_script)
    :ok
  end

  defp exec(cmd, args \\ [], opts \\ []) do
    info "executing: #{inspect cmd} with args #{inspect args}"
    case System.cmd(cmd, args, opts) do
      {output, 0} ->
        IO.puts(output)
        info "created mix project"
      err ->
        IO.puts("ERROR:")
        IO.puts(inspect err)
    end
  end

  defp create_tmp_dir(mix_script) do
    info "creating tmp dir"
    checksum = :crypto.hash(:sha, mix_script) |> Base.encode16(case: :lower)
    tmp_dir = Path.join(System.tmp_dir, checksum)
    File.rm_rf!(tmp_dir)
    File.mkdir_p!(Path.dirname tmp_dir) # create parent
    info "created tmp dir #{tmp_dir}"
    {:ok, tmp_dir}
  end

  @mix_dep_rx ~r/^\s*mix_dep/
  defp parse_script(mix_script_filepath) do
    info "parsing script @ #{mix_script_filepath}"
    {mix_deps_lines, mix_script_lines} =
      File.stream!(mix_script_filepath)
      |> Enum.split_with(fn x -> Regex.match?(@mix_dep_rx, x) end)
    info "Found these deps: #{mix_deps_lines}"
    info "Found this in the script: #{mix_script_lines}"
    mix_deps = mix_deps_lines
               |> Enum.map(fn dep -> String.replace(dep, "mix_dep", "") end)
               |> Enum.join(", ")
               |> String.strip
    mix_deps = "[#{mix_deps}]\n"

    mix_script = """
    defmodule MixScript do
      def main(args) do
        #{mix_script_lines |> Enum.join}
      end
    end
    """

    {mix_deps, mix_script}
  end

  defp compile_mix_project(dir, target_file) do
    exec("mix", ~w(deps.get), cd: dir)
    exec("mix", ~w(escript.build), cd: dir)
    File.cp!(Path.join(dir, "mix_script"), target_file)
  end

end
