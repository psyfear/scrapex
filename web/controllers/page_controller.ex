defmodule Scrapex.PageController do
  use Scrapex.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
