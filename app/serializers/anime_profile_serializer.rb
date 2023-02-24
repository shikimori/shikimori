class AnimeProfileSerializer < AnimeSerializer
  attributes :rating, :english, :japanese, :synonyms, :license_name_ru, :kind, :aired_on,
    :released_on, :episodes, :episodes_aired, :duration, :score, :description,
    :description_html, :description_source, :franchise,
    :favoured, :anons, :ongoing, :thread_id, :topic_id,
    :myanimelist_id,
    :rates_scores_stats, :rates_statuses_stats, :updated_at, :next_episode_at,
    :fansubbers, :fandubbers, :licensors

  has_many :genres
  has_many :studios
  has_many :videos
  has_many :screenshots

  has_one :user_rate, serializer: UserRateFullSerializer

  def user_rate
    object.current_rate
  end

  # TODO: deprecated
  def thread_id
    object.maybe_topic.id
  end

  def topic_id
    object.maybe_topic.id
  end

  def myanimelist_id
    object.id
  end

  def english
    [object.english]
  end

  def japanese
    [object.japanese]
  end

  def description
    object.description.text
  end

  def description_html
    object.description_html.gsub(%r{(?<!:)//(?=\w)}, 'http://')
  end

  def description_source
    object.description.source
  end

  def videos
    object.videos 2
  end

  def screenshots
    object.screenshots 2
  end

  def favoured
    object.favoured?
  end

  def ongoing
    object.ongoing?
  end

  def anons
    object.anons?
  end

  def rates_scores_stats
    (object.stats&.scores_stats || []).map do |entry|
      { name: entry[0].to_i, value: entry[1] }
    end
  end

  def rates_statuses_stats
    (object.stats&.list_stats || []).map do |entry|
      {
        name: I18n.t('activerecord.attributes.user_rate.statuses.' \
          "#{object.class.base_class.name.downcase}.#{entry[0]}"),
        value: entry[1]
      }
    end
  end
end
