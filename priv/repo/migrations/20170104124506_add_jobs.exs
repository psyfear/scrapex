defmodule Scrapex.Repo.Migrations.AddJobs do
  use Ecto.Migration

  def change do
    create table(:jobs) do
      add :name, :string
      add :career_level, :string
      add :url, :string

      timestamps()
    end
  end
end
