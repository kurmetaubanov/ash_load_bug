defmodule AshLoadBug.Cafe.Employee do
  use Ash.Resource,
    otp_app: :rover,
    domain: AshLoadBug.Cafe,
    authorizers: [Ash.Policy.Authorizer],
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  postgres do
    table "employees"
    repo AshLoadBug.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:name]
    end

    update :update do
      primary? true
      accept [:name]
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string, allow_nil?: false
  end

  relationships do
    belongs_to :user, AshLoadBug.Cafe.User

    many_to_many :places, AshLoadBug.Cafe.Place do
      through AshLoadBug.Cafe.EmployeePlace
      source_attribute_on_join_resource :employee_id
      destination_attribute_on_join_resource :place_id
    end
  end

  policies do
    policy action_type(:read) do
      authorize_if {AshLoadBug.Cafe.Check, []}
    end
    
    policy action_type(:create) do
      authorize_if {AshLoadBug.Cafe.Check, []}
    end
    
    policy action_type(:update) do
      authorize_if {AshLoadBug.Cafe.Check, []}
    end
  end
end
