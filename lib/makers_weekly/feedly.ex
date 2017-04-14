defmodule MakersWeekly.Feedly do
  @moduledoc """
  Documentation for Feedly.
  """

  use Tesla, only: ~w(get post)a
  adapter :ibrowse

  @base_url "http://cloud.feedly.com/v3/"
  # @user_id "935f0e82-1c9f-4dc8-867f-8312195d3f85"
  # expires on 2017-04-23
  @access_token "AyJoXreYCFBrxj1DPzSEt4xmgvP2xLH5RkseFQ0P2mlp126vKQqq9l-qYfDNqlkBH-rlcekPjDa-7UySCHbQaaDo-GtfrNTORZ-P6KYEhQI-45kK8rcnL2PR-qupmt-iZGjzKIWO0UNhbZPU1qe-ikVS68smq0kopaijW3-yGSsQaFTCqQ7vVq8tPPfIEmPTIWKZhktV3vxqNvJQNc3YLxO3OriUPS0:feedlydev"
  @category_id "user/935f0e82-1c9f-4dc8-867f-8312195d3f85/category/Maker's Weekly - Engineering"

  plug Tesla.Middleware.BaseUrl, @base_url
  plug Tesla.Middleware.Headers, %{"Authorization" => "OAuth #{@access_token}"}
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Logger
  plug Tesla.Middleware.DebugLogger

  def dump_yaml! do
    yaml = all_subs() |> filter_for_makers_weekly |> to_yaml
    Path.absname("data.yml") |> File.write!(yaml, [])
  end

  # private

  defp all_subs, do: get("/subscriptions").body

  defp to_yaml(subs) when is_list(subs) do
    Enum.reduce(subs, "", fn(sub, accum) ->
      accum
      <>
      """
      - title: #{sub[:title]}
        website: #{sub[:website]}
        icon_url: #{sub[:icon_url]}
        feedly_id: #{sub[:feedly_id]}
        feed_url: #{sub[:feed_url]}
        velocity: #{sub[:velocity]}
        visual_url: #{sub[:visual_url]}
        cover_color: #{sub[:cover_color]}
      """
    end)
  end

  def filter_for_makers_weekly(subs) do
    subs
    |> Enum.filter(fn(sub) -> List.first(sub["categories"])["id"] == @category_id end)
    |> Enum.map(fn(sub) ->
      %{
        id: sub["id"],
        title: sub["title"],
        website: sub["website"],
        icon_url: sub["iconUrl"],
        feedly_id: sub["id"],
        feed_url: (Regex.replace(~r/^feed\//, sub["id"], "")),
        velocity: sub["velocity"],
        visual_url: sub["visualUrl"],
        cover_color: sub["coverColor"]
      }
    end)
  end
end

