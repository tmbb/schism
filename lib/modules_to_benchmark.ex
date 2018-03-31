defmodule ModuleA do
  import Schism

  dogma do
    def f(x) do
      :timer.sleep(50)
      x * 2
    end
  end

  heresy "implementation #2" do
    def f(x) do
      :timer.sleep(100)
      x * 2
    end
  end

  heresy "implementation #3" do
    def f(x) do
      :timer.sleep(200)
      x * 2
    end
  end
end

defmodule ModuleB do
  import Schism

  schism do
    dogma do
      def g(x) do
        :timer.sleep(50)
        {:fast, x * 3}
      end
    end

    heresy "implementation #2" do
      def g(x) do
        :timer.sleep(100)
        {:slow, x * 3}
      end
    end

    heresy "implementation #3" do
      def g(x) do
        :timer.sleep(200)
        {:slowest, x * 3}
      end
    end
  end
end

defmodule ModuleC do
  def h(x), do: x |> ModuleA.f() |> ModuleB.g()
end
