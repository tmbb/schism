defmodule Schism.Testing do
  @doc """
  > “I myself have read the writings and teachings of the heretics, polluting my soul for a while with their abominable notions, though deriving this benefit: I was able to refute them for myself and loathe them even more.”

  * Eusebius, *The Church History*

  The `:schism` library can be used to make your code faster.
  But you must ensure that the *heresies* you want to test are compatible with the *dogma*.
  One way of doing this is by running the same test suites for the heresy and for the dogma.
  The `Schism.Testing` module provides the `Schism.Testing.defsnipped` macro that reduces
  the amount of boilerplate you need.

  The use of this macro is best explained by example.
  First, you define a snippet (don't forget to `require` the `Schism.Testing` module!)

  ```elixir
  require Schism.Testing
  Schism.Testing.defsnippet StructsVsRecordsTestSnippet do
    use ExUnit.Case, async: false

    test "..." do
      # ...
    end

    # ...
  end
  ```

  Then, you can `use` the snippet inside your real testing modules:

  ```elixir
  defmodule StructsVsRecords.StructsAreSuperior do
    use StructsVsRecordsTestSnippet,
      conversions: %{"structs vs records" => "structs are superior"}
  end

  defmodule StructsVsRecords.RecordsAreSuperior do
    use StructsVsRecordsTestSnippet,
      conversions: %{"structs vs records" => "records are superior"}
  end
  ```

  The code above injects the code of the snippet inside your modules and
  makes sure your project is converted to the right beliefs before the tests
  in the module are run.
  For this to work, the snippet injects a `setup_all` macro that handles
  the conversions when the tests start and reverts to the dogma when the tests stop.
  If you need more control, simply omit the `:conversions` option and invoke the
  `setup_all` macro yourself:

  ```elixir
  defmodule StructsVsRecords.RecordsAreSuperior do
    use StructsVsRecordsTestSnippet

    setup_all do
      Schism.convert(%{"structs vs records" => "records are superior"}
      # ... custom setup code ...

      # After all tests are done, convert to the dogma
      on_exit fn ->
        # ... custom teardown code ...
        Schism.convert_to_dogma()
      end
    end
  end

  Tests that use `schism` can't be run with `async: true`, because that will
  break all of the guarantees `schism` needs to work properly.

  ### What is this Sorcery?! Surely it must be... HERESY!

  > “History warns us ... that it is the customary fate of new truths to begin as heresies and to end as superstitions.”

  * Thomas Henry Huxley, *Collected Essays of Thomas Henry Huxley *

  The above looks more magical than it really is...
  The `defsnippet` macro is just a wrapper around `defmodule` that defines
  a `__using__/2` macro so that the module can be used.

  The `__using__/2` macro is defined such that it splices the AST of the snippet
  into the module it's invoked on (it also adds the `setup_all` macro, as defined above).

  If confused, just check the implementation, which is very simple.
  """
  defmacro defsnippet(module_name_ast, [do: body]) do
    # To avoid the complications of unquoting inside several levels
    # of quoting, we build the AST manually
    snippet =
      {:quote, [], [[do: body]]}
    # We need to convert the AST of an alias into an actual alias
    # that can be consumed by `defmodule`
    {module_name, _} = Code.eval_quoted(module_name_ast)
    # Finaly we return an expression that defines a module
    quote do
      defmodule unquote(module_name) do
        # Tests that use `schism` can't be run in parallel,
        # otherwise you can't guarantee under which heresy each test was run.
        use ExUnit.Case, async: false
        @doc false
        defmacro __using__(opts) do
          code_snippet = unquote(snippet)
          conversions = opts[:conversions]
          # If conversions were given
          if conversions do
            quote do
              unquote(code_snippet)

              # Before running the tests, convert the code to the appropriate belief
              setup_all do
                Schism.convert(unquote(conversions))
                # After all tests are done, convert to the dogma
                on_exit fn ->
                  Schism.convert_to_dogma()
                end
              end
            end
          else
            code_snippet
          end
        end
      end
    end
  end
end
