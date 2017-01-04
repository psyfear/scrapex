defmodule Scrapex.Crawler.Jobs do
  use GenServer
  alias Scrapex.Job

  def start_link do
    queue = initial_queue
    GenServer.start_link(__MODULE__, queue)
  end

  def init(queue) do
    schedule_work()
    {:ok, queue}
  end

  #####
  # Callbacks
  #####

  def handle_info(:work, queue) do
    case :queue.out(queue) do
      {{_value, item}, queue_2} ->
        queue = queue_2
        queue = process(item, queue)
        schedule_work()
      _ ->
        IO.puts "Queue is empty - DONE."
        queue = initial_queue
    end
    {:noreply, queue}
  end

  #####
  # Private Methods
  #####

  defp schedule_work do
    Process.send_after(self(), :work, 3000)
  end

  defp process({:page_link, url}, queue) do
    IO.puts "****************************"
    IO.puts "Downloading page: #{url}"
    IO.puts "****************************"

    response = url |> get_response_from_url |> Poison.decode!

    jobs = job_links(response)
    queue = Enum.reduce(jobs, queue, fn job, queue ->
      :queue.in({:job_link, job}, queue)
    end)

    queue
  end

  defp process({:job_link, url}, queue) do
    IO.puts "****************************"
    IO.puts "Downloading job: #{url}"
    IO.puts "****************************"

    html = get_response_from_url(url)

    job_name = Floki.find(html, "h1.visible-xs-block") |> Floki.text
    career_level = Floki.find(html, "[data-partial=job-career-level]")
      |> Floki.attribute("data-partial")
      |> Enum.at(0)

    Scrapex.Data.Jobs.insert_job(job_name, career_level, url)
    queue
  end

  defp job_links(response) do
    %{"data" => data} = response
    jobs = for item <- data do
      %{"name" => name, "slug_and_id" => slug_and_id} = item
      "https://develop.devex.com/jobs/#{slug_and_id}"
    end
    jobs
  end

  defp initial_queue do
    urls = for i <- 1..1 do
      {:page_link, "https://develop.devex.com/api/public/search/jobs?page[number]=#{i}"}
    end
    :queue.from_list(urls)
  end

  defp get_response_from_url(url) do
    response = case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        body
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        IO.puts "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.inspect reason
    end
    response
  end
end
