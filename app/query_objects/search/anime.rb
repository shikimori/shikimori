# how to order by id position
#   https://gist.github.com/cpjolicoeur/3590737#gistcomment-1606739
class Search::Anime < Search::SearchBase
  IGNORED_IDS = Time.zone.today < Date.parse('2023-05-20') ? [1535] : []

  # def order_sql search_ids
    # "censored, #{super}"
  # end
end
