defmodule Logistiki.Events.DefeventTest do
  use ExUnit.Case, async: true

  alias Logistiki.Event

  @without_field """
  defmodule Logistiki.Events.DefeventTest.Plain do
    use Logistiki.Event, type: "plain"

    defevent do
      field :note, :string
    end
  end
  """

  @with_field """
  defmodule Logistiki.Events.DefeventTest.NoImpact do
    use Logistiki.Event, type: "no_impact"

    defevent do
      field :has_accounting_impact, :boolean, default: false
    end
  end
  """

  test "an event without has_accounting_impact compiles without warnings and has impact" do
    warnings = ExUnit.CaptureIO.capture_io(:stderr, fn -> Code.compile_string(@without_field) end)

    assert warnings == ""
    assert {:ok, normalized} = Event.normalize(struct(Logistiki.Events.DefeventTest.Plain))
    assert normalized.has_accounting_impact
  end

  test "an event that declares has_accounting_impact uses its value" do
    ExUnit.CaptureIO.capture_io(:stderr, fn -> Code.compile_string(@with_field) end)

    assert {:ok, normalized} = Event.normalize(struct(Logistiki.Events.DefeventTest.NoImpact))
    refute normalized.has_accounting_impact
  end
end
