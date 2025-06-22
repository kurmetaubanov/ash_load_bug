defmodule AshLoadBug.Cafe.EmployeePlace do
  use Ash.Resource,
    otp_app: :rover,
    domain: AshLoadBug.Cafe,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer

  postgres do
    table "employee_places"
    repo AshLoadBug.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:employee_id, :place_id]
    end
  end

  attributes do
    uuid_primary_key :id

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :employee, AshLoadBug.Cafe.Employee do
      allow_nil? false
    end

    belongs_to :place, AshLoadBug.Cafe.Place do
      allow_nil? false
    end

  end

  policies do
    policy action_type(:read) do
      # authorize_if always()
      authorize_if {AshLoadBug.Cafe.Check, []}
    end

    policy action_type(:create) do
      authorize_if always()
    end

    policy action_type(:update) do
      authorize_if always()
    end

  end
end
