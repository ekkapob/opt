defmodule Opt.RoleChecker do
  alias Opt.Repo
  alias Opt.Role

  def is_admin?(user) do
    (role = Repo.get(Role, user.role_id)) && role.admin
  end
end
