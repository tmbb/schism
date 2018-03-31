defmodule Schism do
  @moduledoc """
  Documentation for Schism.
  """

  @doc false
  def current_belief() do
    Application.get_env(:schism, :belief)
  end

  @doc false
  def convert_to_belief(name) do
    if name in heresies() or name == nil do
      Application.put_env(:schism, :belief, name)
    else
      raise "This belief is not part of any schism..."
    end
  end

  def recompile_code() do
    Mix.Tasks.Compile.Elixir.run(["--force"])
  end

  @doc false
  def heresies() do
    Application.get_env(:schism, :heresies, MapSet.new())
  end

  @doc """
  Test a block of code according to the fundamental dogma.
  """
  def according_to_dogma(fun) do
    {
      fn -> fun.() end,
      before_scenario: fn(resource) ->
        convert_to_belief(nil)
        recompile_code()
        resource
      end
    }
  end

  @doc """
  Test a block of code according to a named heresy.
  """
  def according_to_heresy(name, fun) do
    {
      fn -> fun.() end,
      before_scenario: fn(resource) ->
        convert_to_belief(name)
        recompile_code()
        resource
      end
    }
  end

  @doc false
  def heretic_modules() do
    Application.get_env(:schism, :heretic_modules, MapSet.new())
  end

  @doc false
  def add_to_heretic_modules(module) do
    new_modules = MapSet.put(heretic_modules(), module)
    Application.put_env(:schism, :heretic_modules, new_modules)
  end

  def register_heresy(name) do
    old_heresies = heresies()
    Application.put_env(:schism, :heresies, MapSet.put(old_heresies, name))
  end

  defp is_dogma({:dogma, _, _}), do: true

  defp is_dogma(_), do: false

  defp is_heresy({:heresy, _, _}), do: true

  defp is_heresy(_), do: false

  defp is_heresy_or_dogma(term) do
    is_heresy(term) or is_dogma(term)
  end

  defmacro schism(do: {:__block__, _, calls} = body) do
    case {Enum.all?(calls, &is_heresy_or_dogma/1), Enum.any?(calls, &is_dogma/1)} do
      {true, true} ->
        add_to_heretic_modules(__CALLER__.module)
        body

      {true, false} ->
        raise "This schism doesn't contain a dogma."

      {false, true} ->
        raise "This schism contains something that's neither a dogma nor a heresy."

      {false, false} ->
        raise "This schism contains something that' neither a dogma nor a heresey and does not contain a dogma"
    end
  end

  defmacro heresy(name, do: body) do
    register_heresy(name)
    if current_belief() == name do
      body
    else
      nil
    end
  end

  defmacro dogma(do: body) do
    if current_belief() == nil do
      body
    else
      nil
    end
  end
end
