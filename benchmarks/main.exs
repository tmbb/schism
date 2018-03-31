
Schism.recompile_code()

Benchee.run(%{
  "Fast" => Schism.according_to_dogma(fn -> ModuleC.h(1) end),
  "Slow" => Schism.according_to_heresy("implementation #2", fn -> ModuleC.h(1) end),
  "Slowest" => Schism.according_to_heresy("implementation #3", fn -> ModuleC.h(1) end),
})
