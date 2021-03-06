defmodule Opt.CourseControllerTest do
  use Opt.ConnCase

  alias Opt.Course
  alias Opt.TestHelper

  @valid_attrs %{body: "some content", title: "some content"}
  @invalid_attrs %{}

  setup do
    {:ok, role} = TestHelper.create_role(%{name: "User Role", admin: false})
    {:ok, user} = TestHelper.create_user(role, %{email: "test@test.com",
      username: "testuser", password: "test", password_confirmation: "test"})
    {:ok, course} = TestHelper.create_course(user, %{title: "Test Course",
      body: "Test Body"})
    conn = conn() |> login_user(user)
    {:ok, conn: conn, user: user, role: role, course: course}
  end

  test "lists all entries on index", %{conn: conn, user: user} do
    conn = get conn, user_course_path(conn, :index, user)
    assert html_response(conn, 200) =~ "Listing courses"
  end

  test "renders form for new resources", %{conn: conn, user: user} do
    conn = get conn, user_course_path(conn, :new, user)
    assert html_response(conn, 200) =~ "New course"
  end

  test "creates resource and redirects when data is valid", %{conn: conn,
    user: user} do
    conn = post conn, user_course_path(conn, :create, user), course: @valid_attrs
    assert redirected_to(conn) == user_course_path(conn, :index, user)
    assert Repo.get_by(assoc(user, :courses), @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid",
    %{conn: conn, user: user} do
    conn = post conn, user_course_path(conn, :create, user), course: @invalid_attrs
    assert html_response(conn, 200) =~ "New course"
  end

  test "shows chosen resource", %{conn: conn, user: user, course: course} do
    conn = get conn, user_course_path(conn, :show, user, course)
    assert html_response(conn, 200) =~ "Show course"
  end

  test "renders page not found when id is nonexistent", %{conn: conn, user: user} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, user_course_path(conn, :show, user, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn, user: user,
    course: course} do
    conn = get conn, user_course_path(conn, :edit, user, course)
    assert html_response(conn, 200) =~ "Edit course"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn,
    user: user, course: course} do
    {:ok, role} = TestHelper.create_role(%{name: "Admin", admin: true})
    {:ok, admin} = TestHelper.create_user(role, %{username: "admin",
      email: "admin@test.com", password: "test", password_confirmation: "test"})
    conn =
      login_user(conn, admin)
      |> put user_course_path(conn, :update, user, course),
      course: @valid_attrs
    assert redirected_to(conn) == user_course_path(conn, :show, user, course)
    assert Repo.get_by(Course, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid",
    %{conn: conn, user: user, course: course} do
    conn = put conn, user_course_path(conn, :update, user, course),
      course: %{"body" => nil}
    assert html_response(conn, 200) =~ "Edit course"
  end

  test "deletes chosen resource", %{conn: conn, user: user, course: course} do
    conn = delete conn, user_course_path(conn, :delete, user, course)
    assert redirected_to(conn) == user_course_path(conn, :index, user)
    refute Repo.get(Course, course.id)
  end

  test "redirects when the specified user does not exist", %{conn: conn} do
    conn = get conn, user_course_path(conn, :index, -1)
    assert get_flash(conn, :error) == "Invalid user!"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  test "redirects when trying to edit a post for a different user",
    %{conn: conn, role: role, course: course} do
    {:ok, other_user} = TestHelper.create_user(role, %{email: "test2@test.com",
      username: "test2", password: "test", password_confirmation: "test"})
    conn = get conn, user_course_path(conn, :edit, other_user, course)
    assert get_flash(conn, :error) =~ "not authorized"
    assert redirected_to(conn) == page_path(conn, :index)
    assert conn.halted
  end

  defp login_user(conn, user) do
    post conn, session_path(conn, :create), user: %{username: user.username,
      password: user.password}
  end

end
