class AnimeOnline::AnimeVideoEpisode
  vattr_initialize [:episode, :kinds, :hostings]

  def episode_text
    "##{episode.zero? ? 'прочее' : episode}"
  end

  def kinds
    @sorted_kinds ||= @kinds
      .sort_by { |kind| AnimeVideo.kind.values.index kind.to_s }
      .map(&:to_sym)
  end

  def kinds_text
    kinds
      .map { |kind| I18n.t "#{AnimeVideo.kind.i18n_scopes.first}.#{kind}" }
      .join(', ')
  end

  def hostings
    @sorted_hostings ||= @hostings
      .compact
      .map { |hosting| extract_hosting hosting }
      .sort_by { |hosting| hosting == :vk ? :_ : hosting }
  end

  def hostings_text
    hostings.join(', ')
  end

private

  def extract_hosting hosting
    hosting
      .gsub('mail.ru', 'mailru.ru')
      .gsub(/^(?:.*\.)?([\w-]+)\.\w+$/, '\1').to_sym
  end
end
