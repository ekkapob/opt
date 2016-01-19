defmodule Opt.UserTest do
  use Opt.ModelCase

  alias Opt.User
  alias Opt.TestHelper

  setup do
    {:ok, role} = TestHelper.create_role(%{name: "user", admin: false})
    {:ok, role: role}
  end

  @valid_attrs %{
    email: "some content",
    password: "some content",
    password_confirmation: "some content",
    username: "some content"
  }
  @invalid_attrs %{}

  test "changeset with valid attributes", %{role: role} do
    changeset = User.changeset(%User{}, valid_attrs(role))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  defp valid_attrs(role) do
    Map.put(@valid_attrs, :role_id, role.id)
  end
end
