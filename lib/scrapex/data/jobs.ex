defmodule Scrapex.Data.Jobs do
  use GenServer
  alias Scrapex.Job
  alias Scrapex.Repo

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def insert_job(job_name, career_level, url) do
    GenServer.cast __MODULE__, {:insert_job, {job_name, career_level, url}}
  end

  #####
  # Callbacks
  #####

  def handle_cast({:insert_job, {job_name, career_level, url}}, state) do
    changeset = Job.changeset(%Job{}, %{name: job_name, career_level: career_level, url: url})
    insert_or_update_job(changeset)
    { :noreply, state }
  end

  defp insert_or_update_job(changeset) do
    case Repo.get_by(Job, url: changeset.changes.url) do
      nil ->
        Repo.insert!(changeset)
        IO.puts "****************************"
        IO.puts "Inserted Job: #{changeset.changes.url}"
        IO.puts "****************************"
      job ->
        IO.puts "****************************"
        IO.puts "ALREADY EXISTING Job: #{changeset.changes.url}"
        IO.puts "****************************"
        {:ok, job}
    end
  end
end
