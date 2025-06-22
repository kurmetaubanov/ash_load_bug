defmodule AshLoadBugWeb.ErrorJSONTest do
  use AshLoadBugWeb.ConnCase, async: true

  test "renders 404" do
    assert AshLoadBugWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert AshLoadBugWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
