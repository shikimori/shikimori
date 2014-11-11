# для блока новостей справа на главной странице
class WellcomeNewsPresenter < LazyPresenter
  lazy_loaded :ongoings, :news, :mylist

  LastNewsDate = 3.days.ago
  LastReviewsDate = 5.days.ago

  # ключ от кеша
  def cache_key
    @key ||= WellcomeNewsPresenter.cache_key
  end
  def self.cache_key
    last_news_id = (AnimeNews.last || { id: 'nil' })[:id]

    "#{name}_#{last_news_id}"
  end

  # загрузка данных
  def lazy_load
    @news = Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      AnimeNews
        .wo_episodes
        .where("entries.created_at >= ?", LastNewsDate)
        .joins('inner join animes on animes.id=linked_id and animes.censored=false')
        .includes(:user)
        .order(created_at: :desc)
        .limit(10)
        .to_a
    end
  end

  # последние обзоры
  def reviews
    @reviews ||= Review
      .where("created_at >= ?",  LastReviewsDate)
      .visible
      .includes(:user, :target, thread: [:section])
      .order(created_at: :desc)
      .limit(3)
      .to_a
  end

  # ключ кеша последних обзоров
  def reviews_key
    @reviews_key ||= (Review.last || { id: 'nil' })[:id]
  end

  # последняя активность в группах
  def groups
    @groups ||= GroupComment.includes(:linked)
      .order(updated_at: :desc)
      .limit(3)
      .to_a
  end

  # ключ кеша активности групп
  def groups_key
    @groups_key ||= GroupComment.order(updated_at: :desc).limit(1).map {|v| "#{v.id}-#{v.updated_at}" }.first
  end

  # ключ кеша опросов
  def contests_key
    @contests_key ||= if contests.any?
      "#{contests.map(&:id).map(&:to_s).join(' ')}-#{contests.map(&:updated_at).map(&:to_s).join(' ')}"
    else
      'nil'
    end
  end

  # текущий опрос
  def contests
    @contests ||= Contest.current
  end

  # пояснительный текст к контесту
  def contest_notice contest, user_signed_in, current_user
    if contest.finished?
      "Голосование завершено #{contest.finished_on.strftime '%d.%m.%Y'}"
    else
      if user_signed_in
        if current_user.can_vote?(contest)
          '<span class="can-vote">Проголосуйте</span> за номинантов!'
        else
          if contest.proposing?
            'Предложите своих номинантов'
          elsif contest.started_on > Date.today
            'Голосование ещё не началось'
          else
            'Вы уже проголосовали'
          end
        end
      else
        'Зарегистрируйтесь для участия'
      end
    end
  end
end
