# A dummy benchmark to generate a tble for the docs
# The code here is slightly different from the example code in the docs
Benchee.run(%{
  "structs are superior" => {
    fn _input -> MyLib.ModuleB.w(666) end,
    # Before running the benchmark, recompile the code according to the dogma
    before_scenario: fn _input ->
      Schism.convert(%{"structs vs records" => "structs are superior"},
        extra_files: ["benchmarks/fixtures/modules_a_and_b.exs"])
    end
  },
  "records are superior" => {
    # The code is the same as above, but it's being run under different conditions...
    fn _input -> MyLib.ModuleB.w(666) end,
    # Before running the benchmark, recompile the code according to the heresy
    # The same code will now have better or worse performance.
    before_scenario: fn _input ->
      Schism.convert(%{"structs vs records" => "records are superior"},
      extra_files: ["benchmarks/fixtures/modules_a_and_b.exs"])
    end
  }
})

Schism.convert_to_dogma()
