class AniMangaDecorator < BaseDecorator
  include AniMangaDecorator::UrlHelpers
  include AniMangaDecorator::SeoHelpers

  TopicsPerPage = 4
  NewsPerPage = 12

  instance_cache :topics, :news, :reviews, :reviews_count, :comment_reviews_count, :comment_reviews?
  instance_cache :is_favoured, :favoured, :rate, :thread, :comments, :changes, :roles, :related, :cosplay
  instance_cache :friend_rates, :recent_rates, :chronology

  def source
    object.source
  end

  # топики
  def topics
    object
      .topics
      .wo_generated
      .includes(:section)
      .limit(TopicsPerPage)
      .map { |topic| format_menu_topic topic, :updated_at }
  end

  # новости
  def news
    object
      .news
      .includes(:section)
      .limit(NewsPerPage)
      .map { |topic| format_menu_topic topic, :created_at }
  end

  # обзоры
  def reviews
    ReviewsQuery.new(object, h.current_user, h.params[:id].to_i).fetch.map do |review|
      TopicPresenter.new(
        object: review.thread,
        template: h,
        linked: review,
        limit: 2,
        with_user: true
      )
    end
  end

  # число обзоров
  def reviews_count
    object.reviews.visible.count
  end

  # есть ли обзоры
  def reviews?
    reviews_count > 0
  end

  # добавлено ли в избранное?
  def favoured?
    h.user_signed_in? && h.current_user.favoured?(object)
  end

  # добавившие в избранное
  def favoured
    FavouritesQuery.new(object, 12).fetch
  end

  # добавлено ли в список текущего пользователя?
  def rate
    h.user_signed_in? ? object.rates.find_by_user_id(h.current_user.id) : nil
  end

  # основной топик
  def thread
    object.thread
  end

  # комментарии топика
  def comments with_reviews=false
    if with_reviews && comment_reviews?
      thread.comments.reviews.with_viewed(h.current_user)
    else
      thread.comments.with_viewed(h.current_user)
    end.limit(15).to_a
  end

  # презентер пользовательских изменений
  def changes
    AniMangaPresenter::ChangesPresenter.new object, h
  end

  # презентер с ролями аниме
  def roles
    AniMangaPresenter::RolesPresenter.new object, h
  end

  # презентер связанных аниме
  def related
    AniMangaPresenter::RelatedPresenter.new object, h
  end

  # презентер косплея
  def cosplay
    AniMangaPresenter::CosplayPresenter.new object, h
  end

  # число коментариев
  def comments_count
    thread.comments_count
  end

  # число отзывов
  def comment_reviews_count
    thread.comments.reviews.count
  end

  # есть ли отзывы?
  def comment_reviews?
    comment_reviews_count > 0
  end

  # есть ли хоть какая-то статистика тут?
  def with_stats?
    (object.mal_scores || object.ani_db_scores || object.world_art_scores) && (object.mal_scores && object.mal_scores.sum != 0)
  end

  # оценки друзей
  def friend_rates
    if h.user_signed_in?
      UserRatesQuery.new(object, h.current_user).friend_rates
    else
      []
    end
  end

  # последние изменения от других пользователей
  def recent_rates limit
    UserRatesQuery.new(object, h.current_user).recent_rates limit
  end

  # полная хронология аниме
  def chronology
    ChronologyQuery.new(object, true).fetch
  end

  # показывать ли ссылки, если аниме или манга для взрослых?
  def display_sensitive?
    !object.censored? ||
      (h.user_signed_in? && h.current_user.created_at < DateTime.now - 6.months)
  end

  # есть ли видео для просмотра онлайн?
  def anime_videos?
    object.respond_to?(:anime_videos) && object.anime_videos.worked.any?
  end

private
  def format_menu_topic topic, order
    {
      date: h.time_ago_in_words(topic.send(order), "%s назад"),
      id: topic.id,
      name: topic.to_s,
      title: topic.title,
      tooltip: topic.action == AnimeHistoryAction::Episode,
      url: h.topic_url(topic)
    }
  end

  # имя класса текущего элемента в нижнем регистре
  def klass_lower
    object.class.name.downcase
  end
end
