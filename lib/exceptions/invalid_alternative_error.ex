defmodule BranchPoint.Exceptions.InvalidAlternativeError do
  defexception [:message]

  def exception({branch_point_name, alternative_name}) do
    msg = """
    Invalid alternative #{inspect(alternative_name)} \
    for branch point #{inspect(branch_point_name)}.

    Branch points and the respective alternatives must be explicitly declared
    in the application's config:

      config :branch_point, branch_points: %{
        branch_point1: [
          "alternative #2",
          "alternative #3",
          ...
        ],
        branch_point2: [
          ...
        ],
        ...
      }

    It's possibly that you've forgotten to add this branch point or made a typo somewhere.
    """

    %__MODULE__{message: msg}
  end
end
