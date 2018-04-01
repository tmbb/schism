defmodule BranchPointTest do
  use ExUnit.Case, async: false
  alias BranchPoint.Exceptions.{InvalidAlternativeError, InvalidBranchPointError}
  doctest BranchPoint

  # Helper functions
  defp configured_branch_points() do
    %{
      branch_point1: [
        "implementation #1.2",
        "implementation #1.3"
      ],
      branch_point2: [
        "implementation #2.2",
        "implementation #2.3"
      ]
    }
  end

  defp clean_app_config() do
    Application.delete_env(:branch_point, :branch_points)
    Application.delete_env(:branch_point, :picked)
  end

  defp configure_app() do
    Application.put_env(:branch_point, :branch_points, configured_branch_points())
  end

  defp recompile_testing_modules() do
    Kernel.ParallelCompiler.compile(["test/fixtures/modules_with_branch_points.exs"])
  end

  # clean the app config before each test
  setup do
    clean_app_config()
  end

  test "branch point picks :default alternative by default" do
    configure_app()
    # We need to recompile the testing modules each time
    recompile_testing_modules()
    assert ModuleC.h(1) == {:impl1, 1}
  end

  describe "picking alternatives" do
    test "explicitly picks the default" do
      configure_app()
      BranchPoint.pick_alternatives(branch_point1: :default)
      # We need to recompile the testing modules each time
      recompile_testing_modules()
      assert ModuleC.h(1) == {:impl1, 1}
    end

    test "picks the right alternative (implementation #1.2)" do
      configure_app()
      BranchPoint.pick_alternatives(branch_point1: "implementation #1.2")
      # We need to recompile the testing modules each time
      recompile_testing_modules()
      assert ModuleC.h(1) == {:impl2, 4}
    end

    test "picks the right alternative (implementation #1.3)" do
      configure_app()
      BranchPoint.pick_alternatives(branch_point1: "implementation #1.3")
      # We need to recompile the testing modules each time
      recompile_testing_modules()
      assert ModuleC.h(1) == {:impl3, 9}
    end
  end

  describe "errors in picking alternatives" do
    test "can only pick branch points from the config" do
      configure_app()
      # We need to recompile the testing modules each time
      recompile_testing_modules()

      assert_raise InvalidBranchPointError, fn ->
        BranchPoint.pick_alternatives(branch_point3: "implementation XXX")
      end
    end

    test "can only pick alternatives that exist" do
      configure_app()
      # We need to recompile the testing modules each time
      recompile_testing_modules()

      assert_raise InvalidAlternativeError, fn ->
        # Branch point exists but alternative doesn't
        BranchPoint.pick_alternatives(branch_point1: "implementation XXX")
      end
    end

    test "can only pick alternatives from given branch point" do
      configure_app()
      # We need to recompile the testing modules each time
      recompile_testing_modules()

      assert_raise InvalidAlternativeError, fn ->
        # Both the branch point and the alternative exist, but the alternative
        # blongs to another branch point
        BranchPoint.pick_alternatives(branch_point1: "implementation #2.1")
      end
    end
  end
end
