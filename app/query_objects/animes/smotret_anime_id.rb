class Animes::SmotretAnimeId
  method_object :anime

  NO_ID = -1

  def call
    if anime.association_cached? :all_external_links
      extract_id anime.all_external_links.find(&:kind_smotret_anime?)
    else
      extract_id anime.smotret_anime_external_link
    end
  end

private

  def extract_id external_link
    return unless external_link

    id = external_link.url.split('/').last.to_i
    id if id != NO_ID
  end
end
