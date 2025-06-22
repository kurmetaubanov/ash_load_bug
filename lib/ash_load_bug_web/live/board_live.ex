defmodule AshLoadBugWeb.BoardLive do
  use AshLoadBugWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, users: [], loading: false, message: nil)}
  end

  def handle_event("add_user_with_places", _, socket) do
    socket = assign(socket, loading: true, message: nil)

    try do
      context = %{shared: %{place_permissions?: true}}

      # Create random user
      user_name = "User #{:rand.uniform(1000)}"
      user =
        AshLoadBug.Cafe.User
        |> Ash.Changeset.for_create(:create, %{name: user_name})
        |> Ash.create!(context: context)

      # Create random employee for this user
      employee_name = "Employee for #{user.name}"
      employee =
        AshLoadBug.Cafe.Employee
        |> Ash.Changeset.for_create(:create, %{name: employee_name, user_id: user.id})
        |> Ash.create!(context: context)

      # Create 2-4 random places
      num_places = :rand.uniform(3) + 1
      places =
        Enum.map(1..num_places, fn i ->
          place_name = "Place #{:rand.uniform(1000)}-#{i}"

          AshLoadBug.Cafe.Place
          |> Ash.Changeset.for_create(:create, %{name: place_name})
          |> Ash.create!(context: context)
        end)

      # Connect employee to places through EmployeePlace join records
      Enum.each(places, fn place ->
        AshLoadBug.Cafe.EmployeePlace
        |> Ash.Changeset.for_create(:create, %{
          employee_id: employee.id,
          place_id: place.id
        })
        |> Ash.create!(context: context)
      end)

      socket =
        socket
        |> assign(loading: false, message: "Successfully created user with #{length(places)} places!")
        |> fetch_users()

      {:noreply, socket}
    rescue
      error ->
        {:noreply, assign(socket, loading: false, message: "Error: #{inspect(error)}")}
    end
  end

  def handle_event("fetch_user_with_places", _, socket) do
    socket = assign(socket, loading: true, message: nil)

    try do
      context = %{shared: %{place_permissions?: true}}

      users =
        AshLoadBug.Cafe.User
        |> Ash.Query.load([employee: [places: []]])
        |> Ash.read!(context: context)

      socket =
        socket
        |> assign(loading: false, users: users, message: "Fetched #{length(users)} users with places")

      {:noreply, socket}
    rescue
      error ->
        {:noreply, assign(socket, loading: false, message: "Error: #{inspect(error)}")}
    end
  end

  defp fetch_users(socket) do
    context = %{shared: %{place_permissions?: true}}

    users =
      AshLoadBug.Cafe.User
      |> Ash.Query.load([employee: [places: []]])
      |> Ash.read!(context: context)

    assign(socket, users: users)
  end

  defp message_class(message) do
    if String.contains?(message, "Error") do
      "mb-4 p-3 rounded bg-red-100 text-red-700"
    else
      "mb-4 p-3 rounded bg-green-100 text-green-700"
    end
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto p-6">
      <h1 class="text-3xl font-bold text-gray-900 mb-8">Ash Load Bug Demo</h1>

      <div class="bg-white shadow rounded-lg p-6 mb-6">
        <div class="flex gap-4 mb-6">
          <button
            phx-click="add_user_with_places"
            disabled={@loading}
            class="bg-blue-500 hover:bg-blue-700 disabled:bg-blue-300 text-white font-bold py-2 px-4 rounded"
          >
            <%= if @loading do %>
              Adding...
            <% else %>
              Add User with Places
            <% end %>
          </button>

          <button
            phx-click="fetch_user_with_places"
            disabled={@loading}
            class="bg-green-500 hover:bg-green-700 disabled:bg-green-300 text-white font-bold py-2 px-4 rounded"
          >
            <%= if @loading do %>
              Fetching...
            <% else %>
              Fetch Users with Places
            <% end %>
          </button>
        </div>

        <%= if @message do %>
          <div class={message_class(@message)}>
            <%= @message %>
          </div>
        <% end %>
      </div>

      <%= if length(@users) > 0 do %>
        <div class="bg-white shadow rounded-lg p-6">
          <h2 class="text-xl font-semibold text-gray-900 mb-4">Users and Places</h2>

          <div class="space-y-4">
            <%= for user <- @users do %>
              <div class="border rounded-lg p-4">
                <h3 class="font-medium text-gray-900"><%= user.name %> (ID: <%= String.slice(user.id, 0..7) %>...)</h3>

                <%= if user.employee do %>
                  <p class="text-sm text-gray-600 mt-1">
                    Employee: <%= user.employee.name %> (ID: <%= String.slice(user.employee.id, 0..7) %>...)
                  </p>

                  <%= if length(user.employee.places) > 0 do %>
                    <div class="mt-2">
                      <p class="text-sm font-medium text-gray-700">Places:</p>
                      <ul class="list-disc list-inside text-sm text-gray-600 ml-2">
                        <%= for place <- user.employee.places do %>
                          <li><%= place.name %> (ID: <%= String.slice(place.id, 0..7) %>...)</li>
                        <% end %>
                      </ul>
                    </div>
                  <% else %>
                    <p class="text-sm text-gray-500 mt-2">No places assigned</p>
                  <% end %>
                <% else %>
                  <p class="text-sm text-gray-500 mt-1">No employee record</p>
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
