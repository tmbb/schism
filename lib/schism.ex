defmodule Schism do
  @moduledoc """
  Sets up branch points in the code for conditional compilation.
  """
  alias Schism.Exceptions.InvalidBeliefError

  defp get_belief_name({:heresy, _, [name, _]}), do: name

  defp get_belief_name({:dogma, _, [name, _]}), do: name

  defp get_belief_body({:heresy, _, [_name, [do: body]]}), do: body

  defp get_belief_body({:dogma, _, [_name, [do: body]]}), do: body

  defp pick_belief(:error, _beliefs, dogma), do: {:ok, dogma}

  defp pick_belief({:ok, belief_name}, beliefs, _dogma) do
    case Enum.find(beliefs, fn belief -> get_belief_name(belief) == belief_name end) do
      nil ->
        {:error, :invalid_belief}

      belief ->
        {:ok, belief}
    end
  end

  defp get_dogma(beliefs) do
    Enum.find(beliefs, fn
      {:dogma, _, [_name, [do: _body]]} = dogma -> dogma
      _ -> false
    end)
  end

  defp belief_for_schism(schism_name) do
    picked = Application.get_env(:schism, :picked, %{})
    Map.fetch(picked, schism_name)
  end

  @doc """
  Sets up a branch point for conditional compilation.

  Should be used like this:

  ```elixir

  schism "schism name" do
    # The default option
    dogma "dogma name" do
      # some code
    end

    heresy "heresy #1" do
      # some code...
    end

    heresy "heresy #2" do
      # some code...
    end
  end
  ```
  """
  defmacro schism(schism_name, do: {:__block__, _, beliefs}) do
    maybe_belief_name = belief_for_schism(schism_name)
    dogma = get_dogma(beliefs)
    case pick_belief(maybe_belief_name, beliefs, dogma) do
      {:ok, belief} ->
        get_belief_body(belief)

      {:error, :invalid_belief} ->
        {:ok, belief_name} = maybe_belief_name
        raise InvalidBeliefError, {
          schism_name,
          belief_name
        }
    end
  end

  @doc """
  Picks the beliefs for one or more schisms and recompiles the code.

  Due to the dynamic nature of Elixir's compilation, it can be hard to eliminate all traces
  of heresy and obsolete beliefs that plague your code.
  """
  def force_convert(choices, opts \\ []) when is_map(choices) do
    extra_files = Keyword.get(opts, :extra_files, nil)
    Application.put_env(:schism, :picked, choices)
    # files = Path.wildcard("lib/**/*.ex")
    Mix.Tasks.Compile.Elixir.run(["--force", "--ignore-module-conflict"])
    if extra_files do
      Kernel.ParallelCompiler.compile(extra_files)
    end
    :ok
  end

  @doc """
  Recompile your project according to the dogma.

  Reafirms the one true faith by rejecting heresy and converting into the dogma in all schisms.
  """
  def force_convert_to_dogma(opts \\ []) do
    force_convert(%{}, opts)
  end

  @doc """
  Picks the beliefs for one or more schisms.
  If the beliefs have changed it recompiles the code.

  Unlike `Schism.force_convert/2`, this function only recompiles the code
  if the beliefs have chnaged.
  This is not as safe but avoids useless recompilations which can take up a lot of time.

  Currently, all files are compiled, not only files with schisms.
  Due to the dynamic nature of Elixir's compilation, it can be hard to eliminate all traces
  of heresy and obsolete beliefs that plague your code.
  Purging all BEAM modules and recompiling might be safer.
  For that, use the `Schism.force_convert/2` function.
  """
  def convert(choices, opts \\ []) when is_map(choices) do
    extra_files = Keyword.get(opts, :extra_files, nil)
    currently_picked = Application.get_env(:schism, :picked)
    if currently_picked != choices do
      Application.put_env(:schism, :picked, choices)
      # files = Path.wildcard("lib/**/*.ex")
      Mix.Tasks.Compile.Elixir.run(["--force", "--ignore-module-conflict"])
      if extra_files do
        Kernel.ParallelCompiler.compile(extra_files)
      end
    end
    :ok
  end

  @doc """
  Recompile your project according to the dogma.
  If the project has been compiled accroding to the dogma, it won't be recompiled.

  Reafirms the one true faith by rejecting heresy and converting into the dogma in all schisms.
  """
  def convert_to_dogma(opts \\ []) do
    convert(%{}, opts)
  end
end
