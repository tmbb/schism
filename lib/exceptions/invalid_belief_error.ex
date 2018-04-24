defmodule Schism.Exceptions.InvalidBeliefError do
  defexception [:message]

  def exception({schism_name, belief_name}) do
    msg = """


        Invalid belief #{inspect(belief_name)} for schism #{inspect(schism_name)}

        The belief you converted to is neither the dogma nor a heresy from this schism.
        You can only convert to the truthful dogma or (heavens forbid!) to an
        explicitly listed heresy.
    """

    %__MODULE__{message: msg}
  end
end
