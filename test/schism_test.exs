require Schism.Testing

Schism.Testing.defsnippet SchismTestTemplate do
  use ExUnit.Case, async: false
  doctest Schism

  @extra_files ["test/fixtures/modules_with_schisms.exs"]

  test "schism picks dogma by default" do
    Schism.convert_to_dogma(extra_files: @extra_files)
    assert ModuleC.h(1) == {:impl1, 1}
  end

  describe "conveting to beliefs" do
    test "explicitly convert to the dogma" do
      Schism.convert(%{"schism #1" => "implementation #1.1"}, extra_files: @extra_files)
      assert ModuleC.h(1) == {:impl1, 1}
    end

    test "convert to a heresy (implementation #1.2)" do
      Schism.convert(%{"schism #1" => "implementation #1.2"}, extra_files: @extra_files)
      assert ModuleC.h(1) == {:impl2, 4}
    end

    test "convert to a heresy (implementation #1.3)" do
      Schism.convert(%{"schism #1" => "implementation #1.3"}, extra_files: @extra_files)
      assert ModuleC.h(1) == {:impl3, 9}
    end
  end

  # # Test fails although the correct exception is raised
  # test "convert to invalid heresy" do
  #   assert_raise InvalidBeliefError, fn ->
  #     Schism.convert(%{"schism #1" => "invalid heresy"}, extra_files: @extra_files)
  #   end
  # end
end

# This doubles as a test of the Schism.Testing.defsnippet macro
defmodule SchismTest do
  use SchismTestTemplate
end
