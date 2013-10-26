class SiteScoresService
  MinimumRaates = 50

  def initialize
    @z_score = Recommendations::Normalizations::ZScore.new
    @rates_fetcher ||= Recommendations::RatesFetcher.new Anime
  end

  def calculate
    import_scores sum_scores(fetch_scores)
  end

private
  def fetch_scores
    @rates_fetcher.fetch(@z_score).each_with_object({}) do |(user_id, rates), memo|
      rates.each do |anime_id, rate|
        (memo[anime_id] ||= []) << rate
      end
    end
  end

  def sum_scores(scores)
    scores.each_with_object({}) do |(anime_id, rates), memo|
      memo[anime_id] = rates.sum / rates.size + 1 if rates.size > MinimumRaates
    end
  end

  def import_scores(scores)
    Anime.update_all site_score: 0

    scores.each do |anime_id, score|
      Anime.find(anime_id).update_column :site_score, score
    end

    puts "calculated #{scores.size} scores"
  end
end
