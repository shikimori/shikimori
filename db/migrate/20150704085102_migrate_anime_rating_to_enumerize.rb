class MigrateAnimeRatingToEnumerize < ActiveRecord::Migration
  def up
    Anime.where(rating: 'None').update_all rating: 'none'
    Anime.where(rating: 'G - All Ages').update_all rating: 'g'
    Anime.where(rating: 'PG - Children').update_all rating: 'pg'
    Anime.where(rating: 'PG-13 - Teens 13 or older').update_all rating: 'pg_13'
    Anime.where(rating: 'R - 17+ (violence & profanity)').update_all rating: 'r'
    Anime.where(rating: 'R+ - Mild Nudity').update_all rating: 'r_plus'
    Anime.where(rating: 'Rx - Hentai').update_all rating: 'rx'
  end

  def down
    Anime.where(rating: 'none').update_all rating: 'None'
    Anime.where(rating: 'g').update_all rating: 'G - All Ages'
    Anime.where(rating: 'pg').update_all rating: 'PG - Children'
    Anime.where(rating: 'pg_13').update_all rating: 'PG-13 - Teens 13 or older'
    Anime.where(rating: 'r').update_all rating: 'R - 17+ (violence & profanity)'
    Anime.where(rating: 'r_plus').update_all rating: 'R+ - Mild Nudity'
    Anime.where(rating: 'rx').update_all rating: 'Rx - Hentai'
  end
end
