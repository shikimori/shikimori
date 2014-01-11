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
    last_calendar_id = (AnimeCalendar.last || { id: 'nil' })[:id]
    last_news_id = (AnimeNews.last || { id: 'nil' })[:id]

    "#{self.name}_#{last_calendar_id}_#{last_news_id}"
  end

  # загрузка данных
  def lazy_load
    @ongoings, @news = Rails.cache.fetch(cache_key, expires_in: 3.hours) do
      [
        OngoingsQuery.new.prefetch.take(15),
        AnimeNews.where { action.not_eq(AnimeHistoryAction::Episode) & created_at.gte(LastNewsDate) } # & generated.eq(true)
            .joins('inner join animes on animes.id=linked_id and animes.censored=false')
            .includes(:user)
            .order('created_at desc')
            .limit(10)
            .all
      ]
    end
  end

  def decorated_ongoings
    query = OngoingsQuery.new.process ongoings, nil, false
  end

  # последние обзоры
  def reviews
    @reviews ||= Review.where { created_at.gte LastReviewsDate }
        .visible
        .includes(:user, :target, thread: [:section])
        .order('created_at desc')
        .limit(3)
        .all
  end

  # ключ кеша последних обзоров
  def reviews_key
    @reviews_key ||= (Review.last || { id: 'nil' })[:id]
  end

  # последняя активность в группах
  def groups
    @groups ||= GroupComment.includes(:linked)
      .order { updated_at.desc }
      .limit(3)
      .all
  end

  # ключ кеша активности групп
  def groups_key
    @groups_key ||= GroupComment.order { updated_at.desc }.limit(1).map {|v| "#{v.id}-#{v.updated_at}" }.first
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
