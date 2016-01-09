defmodule Opt.Repo.Migrations.CreateCourse do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :title, :string
      add :body, :string

      timestamps
    end

  end
end
