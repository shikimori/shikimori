class Animes::SmotretAnimeId
  method_object :anime

  def call
    if anime.association_cached? :all_external_links
      extract_id anime.all_external_links.find(&:kind_smotret_anime?)
    else
      extract_id anime.smotret_anime_external_link
    end
  end

private

  def extract_id external_link
    return if !external_link || external_link.url == ExternalLink::NO_URL

    external_link.url.split('/').last.to_i
  end
end
