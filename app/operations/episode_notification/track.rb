class EpisodeNotification::Track
  method_object %i[
    anime_id!
    episode!
    aired_at
    is_raw
    is_subtitles
    is_fandub
    is_anime365
  ]

  EPISODES_MESSAGE = 'invalid episode number: episode > anime.episodes'
  EPISODES_AIRED_MESSAGE = 'invalid episode number: episode >> anime.episodes_aired'

  def call
    model = find_or_initialize

    if @is_raw || @is_subtitles || @is_fandub || @is_anime365
      assign model
      validate model

      if model.errors.none?
        save model
      else
        raise ActiveRecord::RecordNotSaved.new(model.errors[:base][0], model)
      end
    end

    model
  end

private

  def find_or_initialize
    EpisodeNotification.find_or_initialize_by(
      anime_id: @anime_id,
      episode: @episode
    )
  end

  def assign model # rubocop:disable all
    model.is_raw = true if @is_raw
    model.is_subtitles = true if @is_subtitles
    model.is_fandub = true if @is_fandub
    model.is_anime365 = true if @is_anime365

    if model.new_record? && @aired_at.present?
      model.created_at = @aired_at
    end
  end

  def validate model
    model.errors[:base] << EPISODES_MESSAGE if episodes_overflow?(model)
    model.errors[:base] << EPISODES_AIRED_MESSAGE if episodes_aired_overflow?(model)
  end

  def save model
    is_persisted = model.persisted?
    model.save!

    if is_persisted
      EpisodeNotification::TrackEpisode.call model
    end
  end

  def episodes_overflow? model
    model.anime.episodes.positive? &&
      model.episode > model.anime.episodes
  end

  def episodes_aired_overflow? model
    !model.anime.released? && (
      model.episode > model.anime.episodes_aired + maximum_allowed_episode_change(model)
    )
  end

  def maximum_allowed_episode_change model
    case [model.anime.episodes_aired || model.anime.episodes].max
    when 0..12
      3
    when 13..24
      5
    when 25..100
      10
    else
      30
    end
  end
end
