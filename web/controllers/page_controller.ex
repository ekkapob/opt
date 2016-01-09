defmodule Opt.PageController do
  use Opt.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
