defmodule AshLoadBug.Cafe.Check do
    @moduledoc """
    """
    use Ash.Policy.SimpleCheck

    @impl Ash.Policy.Check
    def describe(_), do: "Place Permissions Manager is performing this interaction"

    @impl Ash.Policy.SimpleCheck
    def match?(actor, authorizer, opts) do
      IO.inspect {authorizer.query, authorizer.subject.context, actor, opts}, label: "Place permissions manager performing check"
      case authorizer do
        %{subject: %{context: %{shared: %{place_permissions?: true}}}} -> true
        _ -> false
      end
    end
    # def match?(_, %{subject: %{context: %{shared: %{place_permissions?: true}}}}, _), do: true
    # def match?(_, _, _), do: false
  end
