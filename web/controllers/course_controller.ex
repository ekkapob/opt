defmodule Opt.CourseController do
  use Opt.Web, :controller

  alias Opt.Course

  plug :authorize_user when action in [:new, :create, :update, :edit, :delete]
  plug :assign_user
  plug :scrub_params, "course" when action in [:create, :update]

  def index(conn, _params) do
    courses = Repo.all(assoc(conn.assigns[:user], :courses))
    render(conn, "index.html", courses: courses)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns[:user]
      |> build(:courses)
      |> Course.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"course" => course_params}) do
    changeset =
      conn.assigns[:user]
      |> build(:courses)
      |> Course.changeset(course_params)

    case Repo.insert(changeset) do
      {:ok, _course} ->
        conn
        |> put_flash(:info, "Course created successfully.")
        |> redirect(to: user_course_path(conn, :index, conn.assigns[:user]))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    course = Repo.get!(assoc(conn.assigns[:user],:courses), id)
    render(conn, "show.html", course: course)
  end

  def edit(conn, %{"id" => id}) do
    course = Repo.get!(assoc(conn.assigns[:user], :courses), id)
    changeset = Course.changeset(course)
    render(conn, "edit.html", course: course, changeset: changeset)
  end

  def update(conn, %{"id" => id, "course" => course_params}) do
    course = Repo.get!(assoc(conn.assigns[:user], :courses), id)
    changeset = Course.changeset(course, course_params)

    case Repo.update(changeset) do
      {:ok, course} ->
        conn
        |> put_flash(:info, "Course updated successfully.")
        |> redirect(to: user_course_path(conn, :show, conn.assigns[:user],
        course))
      {:error, changeset} ->
        render(conn, "edit.html", course: course, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    course = Repo.get!(assoc(conn.assigns[:user], :courses), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(course)

    conn
    |> put_flash(:info, "Course deleted successfully.")
    |> redirect(to: user_course_path(conn, :index, conn.assigns[:user]))
  end

  defp assign_user(conn, _) do
    %{"user_id" => user_id} = conn.params
    if user = Repo.get(Opt.User, user_id) do
      assign(conn, :user, user)
    else
      conn
      |> put_flash(:error, "Invalid user!")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

  defp authorize_user(conn, _) do
    user = get_session(conn, :current_user)
    if user && Integer.to_string(user.id) == conn.params["user_id"] do
      conn
    else
      conn
      |> put_flash(:error, "You are not authorized to modify that post!")
      |> redirect(to: page_path(conn, :index))
      |> halt()
    end
  end

end
