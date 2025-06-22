defmodule AshLoadBug.Cafe do
  use Ash.Domain, otp_app: :ash_load_bug, extensions: [AshAdmin.Domain]

  resources do
    resource AshLoadBug.Cafe.User
    resource AshLoadBug.Cafe.Employee
    resource AshLoadBug.Cafe.EmployeePlace
    resource AshLoadBug.Cafe.Place

  end
end
