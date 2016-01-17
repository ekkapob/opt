defmodule Opt.CourseControllerTest do
  use Opt.ConnCase

  alias Opt.Course
  alias Opt.User

  @valid_attrs %{body: "some content", title: "some content"}
  @invalid_attrs %{}

  setup do
    {:ok, user} = create_user
    conn = conn()
    |> login_user(user)
    {:ok, conn: conn, user: user}
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
    IO.inspect user_course_path(conn, :index, user)
    IO.inspect redirected_to(conn)
    assert redirected_to(conn) == user_course_path(conn, :index, user)
    assert Repo.get_by(assoc(user, :courses), @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid",
    %{conn: conn, user: user} do
    conn = post conn, user_course_path(conn, :create, user), course: @invalid_attrs
    assert html_response(conn, 200) =~ "New course"
  end

  test "shows chosen resource", %{conn: conn, user: user} do
    course = build_course(user)
    conn = get conn, user_course_path(conn, :show, user, course)
    assert html_response(conn, 200) =~ "Show course"
  end

  test "renders page not found when id is nonexistent", %{conn: conn, user: user} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, user_course_path(conn, :show, user, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn, user: user} do
    course = build_course(user)
    conn = get conn, user_course_path(conn, :edit, user, course)
    assert html_response(conn, 200) =~ "Edit course"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn,
    user: user} do
    course = build_course(user)
    conn = put conn, user_course_path(conn, :update, user, course), course: @valid_attrs
    assert redirected_to(conn) == user_course_path(conn, :show, user, course)
    assert Repo.get_by(Course, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid",
    %{conn: conn, user: user} do
    course = build_course(user)
    conn = put conn, user_course_path(conn, :update, user, course),
      course: %{"body" => nil}
    assert html_response(conn, 200) =~ "Edit course"
  end

  test "deletes chosen resource", %{conn: conn, user: user} do
    course = build_course(user)
    conn = delete conn, user_course_path(conn, :delete, user, course)
    assert redirected_to(conn) == user_course_path(conn, :index, user)
    refute Repo.get(Course, course.id)
  end

  defp create_user do
    User.changeset(%User{}, %{email: "test@test.com", username: "test",
      password: "test", password_confirmation: "test"})
    |> Repo.insert
  end

  defp login_user(conn, user) do
    post conn, session_path(conn, :create), user: %{username: user.username,
      password: user.password}
  end

  defp build_course(user) do
    changeset =
      user
      |> build(:courses)
      |> Course.changeset(@valid_attrs)
    Repo.insert!(changeset)
  end
end
