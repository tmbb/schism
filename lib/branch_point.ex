defmodule BranchPoint do
  @moduledoc """
  Sets up branch points in the code for conditional compilation.
  """
  alias BranchPoint.Exceptions.{InvalidAlternativeError, InvalidBranchPointError}

  defp get_alternative_name({:alternative, _, [name, _]}), do: name

  defp get_alternative_name({:default, _, _}), do: :default

  defp get_alternative_body({:alternative, _, [_, [do: body]]}), do: body

  defp get_alternative_body({:default, _, [[do: body]]}), do: body

  defp pick_alternative(alternative_name, alternatives, default) do
    case Enum.find(alternatives, fn alternative ->
           get_alternative_name(alternative) == alternative_name
         end) do
      nil -> default
      alternative -> alternative
    end
  end

  defp get_default(alternatives) do
    Enum.find(alternatives, fn
      {:default, _, _} -> :default
      _ -> false
    end)
  end

  defp alternative_for_branch_point(branch_point_name) do
    picked = Application.get_env(:branch_point, :picked, [])

    case Enum.find(picked, fn
           {^branch_point_name, _alternative_name} -> true
           _ -> false
         end) do
      {_, alternative_name} -> alternative_name
      nil -> :default
    end
  end

  defp validate_branch_point!(branch_point_name) do
    branch_point_data = Application.get_env(:branch_point, :branch_points, %{})

    if branch_point_name in Map.keys(branch_point_data) do
      nil
    else
      raise InvalidBranchPointError, branch_point_name
    end
  end

  defp validate_alternative_for_branch_point!(branch_point_name, alternative_name) do
    branch_point_data = Application.get_env(:branch_point, :branch_points, %{})
    alternatives_for_branch_point = Map.get(branch_point_data, branch_point_name, [])

    if alternative_name == :default or alternative_name in alternatives_for_branch_point do
      nil
    else
      raise InvalidAlternativeError, {branch_point_name, alternative_name}
    end
  end

  @doc """
  Sets up a branch point for conditional compilation.
  """
  defmacro branch_point(branch_point_name, do: {:__block__, _, alternatives}) do
    validate_branch_point!(branch_point_name)
    alternative_name = alternative_for_branch_point(branch_point_name)
    validate_alternative_for_branch_point!(branch_point_name, alternative_name)
    default = get_default(alternatives)

    if Mix.env() in [:dev, :test] do
      alternative = pick_alternative(alternative_name, alternatives, default)
      get_alternative_body(alternative)
    else
      get_alternative_body(default)
    end
  end

  @doc """
  Picks the alternatives for one or more branch points and recompiles the code.

  Currently, all files are compiled, not only files with branch points.
  Due to the dynamic nature of Elixir's compilation, this is the safest option.
  In the future `BranchPoint` might detect compile-time dependencies and only compile
  modules that depend on modules containing branch points.
  """
  def pick_alternatives(choices) when is_list(choices) do
    for {branch_point_name, alternative_name} <- choices do
      validate_branch_point!(branch_point_name)
      validate_alternative_for_branch_point!(branch_point_name, alternative_name)
    end

    Application.put_env(:branch_point, :picked, choices)
    Mix.Tasks.Compile.Elixir.run(["--force"])
  end
end
