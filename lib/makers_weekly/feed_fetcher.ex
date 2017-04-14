defmodule MakersWeekly.FeedFetcher do
  @default_feed_data_file "data.yml"

  use Tesla, only: ~w(get)a

  adapter :ibrowse
  plug Tesla.Middleware.FollowRedirects
  plug Tesla.Middleware.Logger
  # plug Tesla.Middleware.DebugLogger

  def fetch_all do
    parse_feed_data()
    |> Enum.map(fn(sub) ->
      Task.async(fn -> fetch(sub["feed_url"]) end)
    end)
    |> Enum.map(&Task.await(&1, :infinity))
  end

  def fetch(feed_url) do
    get(feed_url).body
    |> ElixirFeedParser.parse()
  end

  def parse_feed_data(file_name \\ @default_feed_data_file) do
    file_name
    |> Path.absname()
    |> YamlElixir.read_from_file()
  end
end
