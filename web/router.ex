defmodule Opt.Router do
  use Opt.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Opt do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    # resources "/courses", CourseController
    resources "/users", UserController do
      resources "/courses", CourseController
    end
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Opt do
  #   pipe_through :api
  # end
end
