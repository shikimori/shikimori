UserRates::StructEntry = Struct.new(
  :id,
  :score,
  :text,
  :episodes,
  :volumes,
  :chapters,
  :rewatches,
  :target_id,
  :target_class_downcased,
  :target_name,
  :target_russian,
  :target_url,
  :target_episodes,
  :target_episodes_aired,
  :target_episode_duration,
  :target_volumes,
  :target_chapters,
  :target_kind,
  :target_year,
  :target_image_file_name,
  :target_is_ongoing,
  :target_is_anons
)

class UserRates::StructEntry
  URL_PREFIX = {
    'Anime' => 'animes',
    'Manga' => 'mangas',
    'Ranobe' => 'ranobe'
  }

  def self.create user_rate # rubocop:disable all
    is_anime = user_rate.target_type == 'Anime'
    target = is_anime ? user_rate.anime : user_rate.manga
    target_class_downcased = target.class.name.downcase

    UserRates::StructEntry.new(
      user_rate.id,
      user_rate.score,
      user_rate.text,
      user_rate.episodes,
      user_rate.volumes,
      user_rate.chapters,
      user_rate.rewatches,
      user_rate.target_id,
      target_class_downcased,
      target.name,
      target.russian,
      "/#{URL_PREFIX[target.class.name]}/" +
        CopyrightedIds.instance.change(user_rate.target_id, target_class_downcased),
      (target.episodes if is_anime),
      (target.episodes_aired if is_anime),
      (target.duration if is_anime),
      (target.volumes unless is_anime),
      (target.chapters unless is_anime),
      target.kind.to_s,
      target.year,
      target.image_file_name,
      target.ongoing?,
      target.anons?
    )
  end

  def text_html
    BbCodes::CachedText.call text
  end
end
