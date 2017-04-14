defmodule MakersWeekly.FeedFetcher do
  use Tesla, only: ~w(get)a
  adapter :ibrowse

end
