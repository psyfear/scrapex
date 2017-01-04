defmodule Scrapex.Job do
  use Scrapex.Web, :model

  schema "jobs" do
    field :name, :string
    field :career_level, :string
    field :url, :string

    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, ~w(name career_level url), [])
    |> validate_required([:url])
  end
end
