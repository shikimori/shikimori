class EpisodeNotifications::Track
  method_object %i[anime_id! episode! is_raw is_torrent is_unknown is_subtitles is_fandub]

  def call
    model = find_or_initialize

    if @is_raw || @is_torrent || @is_unknown || @is_subtitles || @is_fandub
      assign model
      save model
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

  def assign model
    model.is_raw = true if @is_raw
    model.is_torrent = true if @is_torrent
    model.is_unknown = true if @is_unknown
    model.is_subtitles = true if @is_subtitles
    model.is_fandub = true if @is_fandub
  end

  def save model
    model.save!
  end
end
