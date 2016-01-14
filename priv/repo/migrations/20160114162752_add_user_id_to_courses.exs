defmodule Opt.Repo.Migrations.AddUserIdToCourses do
  use Ecto.Migration

  def change do
    alter table(:courses) do
      add :user_id, references(:users)
    end
    create index(:courses, [:user_id])
  end
end
