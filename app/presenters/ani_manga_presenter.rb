class AniMangaPresenter < BasePresenter
  include UrlsHelper

  TopicsPerPage = 4
  NewsPerPage = 12

  presents :entry
  proxy :id, :name, :russian, :image, :genres, :with_score?, :score, :source,
        :mal_scores, :kind, :aired_at, :released_at, :description, :description_html, :description_mal,
        :tags, :to_param, :images, :anons?, :censored?
  respond_proxy :studios, :publishers, :real_studios, :real_publishers, :episodes, :chapters,
                :read_manga_name, :read_manga_id, :world_art_id, :world_art_scores,
                :ani_db_id, :ani_db_scores, :torrents_name, :read_manga_url, :read_manga_scores

  # топики аниме
  def topics
    @topics ||= entry.topics
        .wo_generated
        .includes(:section)
        .limit(TopicsPerPage)
        .map { |topic| format_menu_topic topic, :updated_at }
  end

  # новости аниме
  def news
    @news ||= entry.news
        .includes(:section)
        .limit(NewsPerPage)
        .map { |topic| format_menu_topic topic, :created_at }
  end

  # может ли объект быть презентован
  def self.presentable?(element)
    element.class == Anime || element.class == Manga
  end

  # все обзоры аниме
  def reviews
    @reviews = ReviewsQuery.new(entry, current_user, params[:id].to_i).fetch.map do |review|
      TopicPresenter.new({
        object: review.thread,
        template: @view_context,
        linked: review,
        limit: 2,
        with_user: true
      })
    end
  end

  # число обзоров к аниме
  def reviews_count
    @reviews_count ||= entry.reviews.visible.count
  end

  # есть ли обзоры к аниме?
  def reviews?
    reviews_count > 0
  end

  # добавлено ли аниме в избранное?
  def favoured?
    @is_favoured ||= user_signed_in? && current_user.favoured?(entry)
  end

  # добавившие в избранное аниме
  def favoured
    @favoured ||= FavouritesQuery.new(entry, 12).fetch
  end

  # добавлено ли аниме в список?
  def rate
    @rate ||= user_signed_in? ? entry.rates.find_by_user_id(current_user.id) : nil
  end

  # скриншоты к аниме
  def screenshots(limit=nil)
    (@screenshots ||= {})[limit] ||= if entry.respond_to? :screenshots
      entry.screenshots.limit limit
    else
      []
    end
  end

  # видео к аниме
  def videos(limit=nil)
    (@videos ||= {})[limit] ||= if entry.respond_to? :videos
      entry.videos.limit limit
    else
      []
    end
  end

  # аниме ли это?
  def anime?
    entry.class == Anime
  end

  # основной топик
  def thread
    @thread ||= entry.thread
  end

  # комментарии топика
  def comments(with_reviews=false)
    @comments ||= if with_reviews && comment_reviews?
      thread.comments.reviews.with_viewed(current_user).limit(15)
    else
      thread.comments.with_viewed(current_user).limit(15)
    end
  end

  # презентер пользовательских изменений
  def changes
    @changes ||= ChangesPresenter.new entry, @view_context
  end

  # презентер с ролями а аниме
  def roles
    @roles ||= RolesPresenter.new entry, @view_context
  end

  # презентер связанных аниме
  def related
    @related ||= RelatedPresenter.new entry, @view_context
  end

  # презентер файлов
  def files
    @files ||= FilesPresenter.new entry, @view_context
  end

  # презентер косплея
  def cosplay
    @cosplay ||= CosplayPresenter.new entry, @view_context
  end

  # число коментариев к аниме
  def comments_count
    thread.comments_count
  end

  # число отзывов к аниме
  def comment_reviews_count
    @comment_reviews_count ||= thread.comments.reviews.count
  end

  # есть ли отзывы к аниме?
  def comment_reviews?
    @has_comment_reviews ||= comment_reviews_count > 0
  end

  # есть ли хоть какая-то статистика тут?
  def with_stats?
    (entry.mal_scores || entry.ani_db_scores || entry.world_art_scores) && (entry.mal_scores && entry.mal_scores.sum != 0)
  end

  # оценки друзей
  def friend_rates
    @friend_rates ||= if user_signed_in?
      UserRatesQuery.new(entry, current_user).friend_rates
    else
      []
    end
  end

  # последние изменения от других пользователей
  def recent_rates(limit)
    @recent_rates ||= UserRatesQuery.new(entry, current_user).recent_rates limit
  end

  # полная хронология аниме
  def chronology
    @chronology ||= ChronologyQuery.new(entry, true).fetch
  end

  # главный сео жанр аниме
  def main_genre
    genre = entry.genres.sort_by(&:seo).first
    genres = entry.genres.select { |v| v.seo == genre.seo }

    genres[entry.id % genres.size - 1]
  end

  # ролики, отображаемые на инфо странице аниме
  def main_videos
    @main_videos ||= entry.videos.limit(2)
  end

  def seo_keywords
    [
      entry.name, entry.russian,
      (entry.synonyms || '').join(', '),
      (entry.english || '').join(', '),
      "#{anime? ? 'аниме' : 'манга'} #{entry.short_name}",
      "#{entry.short_name} персонажи",
      "#{entry.short_name} обсуждение",
      (cosplay.characters.any? ? "#{entry.short_name} косплей" : nil),
      (reviews? ? "#{entry.short_name} обзоры, рецензии, отзывы" : '')
    ].select(&:present?).join(', ')
  end

  def seo_description
    ani_manga_description entry, 310
  end

private
  def format_menu_topic(topic, order)
    {
      date: time_ago_in_words(topic.send(order), "%s назад"),
      id: topic.id,
      name: topic.to_s,
      title: topic.title,
      tooltip: topic.action == AnimeHistoryAction::Episode,
      url: topic_url(topic)
    }
  end

  # имя класса текущего элемента в нижнем регистре
  def klass_lower
    entry.class.name.downcase
  end
end
