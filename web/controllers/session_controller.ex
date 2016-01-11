defmodule Opt.SessionController do
  use Opt.Web, :controller

  def new(conn, _params) do
    render conn, "new.html"
  end
end
