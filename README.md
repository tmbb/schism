# Schism

> “It is dangerous to be right in matters on which the established authorities are wrong.”

* Voltaire, *The Age of Louis XIV*

Forbidden library that contains macros for conditional compilation of Elixir code.

## Installation

Currently, this package is only available on GitHub.

## Motivation

While a library with such a heretical name as schism?

Suppose, fellow citizen, that your pious code contains a deeply nested stack of functions
(as it should, for a function should do one thing and one thing only).

Your code might well end up like this:

```elixir
defmodule MyLib.ModuleA do
  def f(x) do
    # ...
  end

  def g(x) do
    # ...
    y = f(x)
    # ...
  end

  def h(x) do
    # ...
    y = g(x)
    # ...
  end
end

defmodule MyLib.ModuleB do
  def w(x) do
    # ...
    y = ModuleA.f(x)
    # ...
  end
end
```

Now suppose further that your code is slow.
Such code will be wasteful and consume valuable CPU cycles.
Such waste is abhorrent, and naturally heretical in nature.

This is an unacceptable state of affairs!
You must find the source of slowness, root it out with extreme prejudice and
document it publicly so that such wasteful lines of code shall never know
the light of day again.

You must profile your code, detect the problem and benchmark your functions
to guarantee you've improved performance.

So far, the best options is to allow the [Benchee](https://github.com/PragTob/benchee)
to possess your code and document the performance improvements.

However, let's say you care about the performance of the function `MyLib.ModuleB.w/1` defined above, and that you manage to fix a performance problem in the function `MyLib.ModuleA.f/1`. You want to benchmark the performance of `w/1` under the new conditions and compare it to the performance under the old conditions.

This would usually require you to compile the code, benchmark it and save the Benchee charts for future comparison. Then, you'd have to apply your changes, recompile,
run the benchmark and "manually" compare the Benchee data.

This is far from ideal.
You'd like to be able to compare the before/after performance directly in the same chart.
One solution is to define an extra module such as `MyLib.ModuleA__Temp` with the changes you want and compare the performance to the old module.
This usually require a lot of copy and paste, which is quite error prone
(for the nature of Man is to be imperfect, and imperfect we are), and if the function you want to test is in a different module you have to copy that module too.

Things need not to be so complex.

You don't need to copy and paste, and you don't need extra modules.

This might be a sign that your dogmatic code has gone stale under the yoke of the
Official Truth.

You need to distance yourself from the dogmatic tyrants of the past.

You need... a [Schism](https://en.wikipedia.org/wiki/Schism)!

A schism will allow you to have conditional compilation on your modules, and will allow you to choose between the (so called) truthful dogma and several heresies, to pick the one with the most favorable performance characteristics.

## Turning to Heresy and Abandoning the Dogma

> “The world is kept alive only by heretics: the heretic Christ, the heretic Copernicus, the heretic Tolstoy. Our symbol of faith is heresy. (*Tomorrow*)”

* Yevgeny Zamyatin

Let us then abandon the obsolete orthodoxy and embrace the heretical ideas of change:

```elixir
defmodule MyLib.ModuleA do
  # Taint your code with the seeds of doubt and heresy
  import Schism

  schism "structs vs records" do
    # boldly reafirm the dogma of the elixir:
    dogma "structs are superior"
      def f(x) do
        # implementation of `f/1` that uses structs
      end
    end

    # Spread the hateful screed that the old rusty records from Erlang
    # might still have a place in code written today, despite their
    # archaic and primitive nature
    heresy "records are superior"
      def f(x) do
        # implementation of `f/1` that uses records
      end
    end
  end

  # The rest of the module remains the same at visual inspection,
  # although it is now tainted by heresy...
  # Through conditional compilation, the meaning of all this
  # functions may  be changed as they are corrupted
  # by the heretical ideas that defy the dogma
  def g(x) do
    # ...
    y = f(x)
    # ...
  end

  def h(x) do
    # ...
    y = g(x)
    # ...
  end
end

defmodule MyLib.ModuleB do
  # Now, when you call functions from MyLib.ModuleA,
  # you'll be calling functions already corrupted by heresy.
  def w(x) do
    # ...
    y = MyLib.ModuleA.f(x)
    # ...
  end
end
```

By default, the `Schism.schism/2` macro will compile the `dogma` branch
and discard the heresies

You can now write the following benchmark:

```elixir
# benchmarks/structs_vs_records.exs
Benchee.run(%{
  "structs are superior" => {
    fn _input -> MyLib.ModuleB.w(666) end,
    # Before running the benchmark, recompile the code according to the dogma
    before_scenario: fn _input ->
      Schism.convert(%{"structs vs records" => "structs are superior"})
    end
  },
  "records are superior" => {
    # The code is the same as above, but it's being run under different conditions...
    fn _input -> MyLib.ModuleB.w(666) end,
    # Before running the benchmark, recompile the code according to the heresy
    # The same code will now have better or worse performance.
    before_scenario: fn _input ->
      Schism.convert(%{"structs vs records" => "records are superior"})
    end
  }
})
```

As usual, you can run the benchmark using:

```console
mix run benchmarks/structs_vs_records.exs
```

And the mix task will print something like the following:

```console
Operating System: Windows"
CPU Information: Intel(R) Core(TM) i7-6700HQ CPU @ 2.60GHz
Number of Available Cores: 8
Available memory: 7.87 GB
Elixir 1.6.2
Erlang 20.0

Benchmark suite executing with the following configuration:
warmup: 2 s
time: 5 s
memory time: 0 μs
parallel: 1
inputs: none specified
Estimated total run time: 14 s


Benchmarking records are superior...
Compiling 3 files (.ex)
Benchmarking structs are superior...
Compiling 3 files (.ex)

Name                           ips        average  deviation         median         99th %
records are superior             4         250 ms     ±0.00%         250 ms         250 ms
structs are superior          2.13      468.73 ms     ±0.10%         469 ms         469 ms

Comparison:
records are superior             4
structs are superior          2.13 - 1.87x slower
```

What does this code do?

This code defines a `before_scenario` hook for Benchee.
This is a function that should run before the benchmark.
In this case, the `Schism.convert/1` function converts the code into the
"correct" set of beliefs for each schism.
This entails recompiling the code and picking the correct dogma or heresy
everywhere the `schism` macro is used.
If no belief is specified for a given schism, the `dogma` will be picked instead.

You can confirm from the logs above that the code has been compiled twice,
as we would expect.

The `Schism.convert/1` function depends on Mix, so it can only be used in development,
and not in production where Mix won't be available.
This doubles as a safety measure, as you most definitely don't want to conditionally
recompile your code at runtime in production.
Such action is heretical, and will be met with extreme disapproval from your peers!

For added safety in some very unlikely edge cases, the `Schism.force_convert/1` function
may be used instead of `Schism.convert/1`

## Ensuring Compatibility of Beliefs

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
```

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

## Should I Allow the Taint of Heresy into my Elixir Project?!

Using `schism` is safe in production, because the `dogma` will be chosen every time
and the heresies will simply be discarded.

The conversion functions `Schism.convert/2`, `Schism.force_convert/2`,
`Schism.convert_to_dogma/1` and `Schism.force_convert_to_dogma/1` depend on Mix
and will fail if invoked in production.

The only drawback is that you're adding yet another dependency to your project.
Although `schism` doesn't do much at runtime, you really require the `schism` macro
for this to work in production.