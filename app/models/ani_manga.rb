module AniManga
  extend ActiveSupport::Concern

  ONGOING_TO_RELEASED_DAYS = 2

  included do
    has_one :stats,
      class_name: 'AnimeStat',
      as: :entry,
      inverse_of: :entry,
      dependent: :destroy

    has_many :anime_stat_histories,
      as: :entry,
      inverse_of: :entry,
      dependent: :destroy

    validates :name, presence: true
    validates :description_ru, :description_en, length: { maximum: 16_384 }
    validates :name, :english, :russian, :japanese, :franchise, :license_name_ru,
      length: { maximum: 255 }
  end

  def year
    aired_on&.year
  end

  # если жанров слишком много, то оставляем только 6 основных
  def main_genres
    all_genres = genres.sort_by { |v| Genre::LONG_NAME_GENRES.include?(v.english) ? 0 : v.id }
    return all_genres if genres.size <= 5

    selected_genres = genres.select(&:main?)

    all_genres.each do |genre|
      break if selected_genres.size > 5

      selected_genres << genre unless selected_genres.include? genre
    end

    selected_genres.sort_by { |v| Genre::LONG_NAME_GENRES.include?(v.english) ? 0 : v.id }
  end

  # из списка студий/издателей аниме возвращает единственного настоящего
  %w[studios publishers].each do |kind|
    define_method "real_#{kind}" do
      return [] if send(kind).empty?
      return send(kind).map(&:real) if send(kind).size == 1

      @real_st_pub_cache ||= send(kind).map(&:real).select(&:is_visible?)
      @real_st_pub_cache.empty? ? send(kind).map(&:real) : @real_st_pub_cache
    end
  end

  # есть ли оценка?
  def with_score?
    score > 1.0 && score < 9.9 && !anons?
  end

  def generate_name_matches
    NameMatches::Refresh.perform_async self.class.name, id
  end

  def image_file_name
    rkn_abused? ? nil : super
  end
end
