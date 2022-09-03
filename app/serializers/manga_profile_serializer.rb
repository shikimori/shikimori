class MangaProfileSerializer < MangaSerializer
  attributes :english, :japanese, :synonyms, :kind, :license_name_ru, :aired_on, :released_on,
    :volumes, :chapters, :score,
    :description, :description_html, :description_source, :franchise,
    :favoured, :anons, :ongoing, :thread_id, :topic_id,
    :myanimelist_id,
    :rates_scores_stats, :rates_statuses_stats,
    :licensors

  has_many :genres
  has_many :publishers

  has_one :user_rate, serializer: UserRateFullSerializer

  def description
    object.description.text
  end

  def user_rate
    object.current_rate
  end

  def english
    [object.english]
  end

  def japanese
    [object.japanese]
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

  def description
    object.description.text
  end

  def description_html
    object.description_html.gsub(%r{(?<!:)//(?=\w)}, 'http://')
  end

  def description_source
    object.description.source
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
      { name: entry['key'].to_i, value: entry['value'] }
    end
  end

  def rates_statuses_stats
    (object.stats&.list_stats || []).map do |entry|
      {
        name: I18n.t('activerecord.attributes.user_rate.statuses.' \
          "#{object.class.base_class.name.downcase}.#{entry['key']}"),
        value: entry['value']
      }
    end
  end
end
