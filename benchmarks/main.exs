Benchee.run(%{
  "Fast" => {
    fn _input -> ModuleC.h(1) end,
    before_scenario: fn _input -> BranchPoint.pick(branch_point1: :default) end
  },
  "Slow" => {
    fn _input -> ModuleC.h(1) end,
    before_scenario: fn _input -> BranchPoint.pick(branch_point1: "implementation #2") end
  },
  "Slowest" => {
    fn _input -> ModuleC.h(1) end,
    before_scenario: fn _input -> BranchPoint.pick(branch_point1: "implementation #3") end
  }
})
