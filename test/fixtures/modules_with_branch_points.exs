# Modules with branch points we want to test
defmodule ModuleA do
  import BranchPoint

  branch_point :branch_point1 do
    default do
      def f(x) do
        x * 1
      end
    end

    alternative "implementation #1.2" do
      def f(x) do
        x * 2
      end
    end

    alternative "implementation #1.3" do
      def f(x) do
        x * 3
      end
    end
  end
end

defmodule ModuleB do
  import BranchPoint

  branch_point :branch_point1 do
    default do
      def g(x) do
        {:impl1, x * 1}
      end
    end

    alternative "implementation #1.2" do
      def g(x) do
        {:impl2, x * 2}
      end
    end

    alternative "implementation #1.3" do
      def g(x) do
        {:impl3, x * 3}
      end
    end
  end
end

defmodule ModuleC do
  def h(x), do: x |> ModuleA.f() |> ModuleB.g()
end
