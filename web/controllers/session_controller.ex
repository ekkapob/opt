defmodule Opt.SessionController do
  use Opt.Web, :controller
  alias Opt.User
  import Comeonin.Bcrypt, only: [checkpw: 2]

  plug :scrub_params, "user" when action in [:create]

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => %{"username" => username,
    "password" => password}}) when not is_nil(username) and
    not is_nil(password) do
    user = Repo.get_by(User, username: username)
    user
    |> sign_in(password, conn)
  end

  def create(conn, _params) do
    failed_login(conn)
  end

  def delete(conn, _params) do
    conn
      |> delete_session(:current_user)
      |> put_flash(:info, "Signed out successfully!")
      |> redirect(to: page_path(conn, :index))
  end

  defp failed_login(conn) do
    conn
    |> put_session(:current_user, nil)
    |> put_flash(:error, "Either username or password is invalid!")
    |> redirect(to: page_path(conn, :index))
    |> halt()
  end

  defp sign_in(user, _password, conn) when is_nil(user) do
    failed_login(conn)
  end

  defp sign_in(user, password, conn) do
    if checkpw(password, user.password_digest) do
      conn
      |> put_session(:current_user, %{id: user.id, username: user.username,
        role_id: user.role_id})
      |> put_flash(:info, "Sign in successful!")
      |> redirect(to: page_path(conn, :index))
    else
      failed_login(conn)
    end
  end
end
