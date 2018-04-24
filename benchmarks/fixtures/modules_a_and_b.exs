defmodule MyLib.ModuleA do
  # Taint your code with the seeds of doubt and heresy
  import Schism

  schism "structs vs records" do
    # boldly reafirm the dogma of the elixir:
    dogma "structs are superior" do
      def f(x) do
        # implementation of `f/1` that uses structs
        :timer.sleep(460)
        x
      end
    end

    # Spread the hateful screed that the old rusty records from Erlang
    # might still have a place in code written today, despite their
    # archaic and primitive nature
    heresy "records are superior" do
      def f(x) do
        # implementation of `f/1` that uses records
        :timer.sleep(250)
        x
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
    y
  end

  def h(x) do
    # ...
    y = g(x)
    # ...
    y
  end
end

defmodule MyLib.ModuleB do
  # Now, when you call functions from MyLib.ModuleA,
  # you'll be calling functions already corrupted by heresy.
  def w(x) do
    # ...
    y = MyLib.ModuleA.f(x)
    # ...
    y
  end
end
