defmodule Opt.SessionController do
  use Opt.Web, :controller
  alias Opt.User
  import Comeonin.Bcrypt, only: [checkpw: 2]

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => %{"username" => username},
    "password" => password}) when not is_nil(username) and
    not is_nil(password) do
    user = Repo.get_by(User, username: username)
    user
    |> sign_in(password, conn)
  end

  def create(conn, _params) do
    failed_login(conn)
  end

  def sign_in(user, password, conn) when is_nil(user) do
    conn
    |> put_flash(:error, "Either username or password is invalid!")
    |> redirect(to: page_path(conn, :index))
  end

  def sign_in(user, password, conn) do
    if checkpw(password, user.password_digest) do
      conn
      |> put_session(:current_user, %{id: user.id, username: user.username})
      |> put_flash(:info, "Sign in successful!")
      |> redirect(to: page_path(conn, :index))
    else
      conn
      |> put_session(:current_user, nil)
      |> put_flash(:error, "Either username or password is invalid!")
      |> redirect(to: page_path(conn, :index))
    end
  end
end
