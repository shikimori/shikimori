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
      .map { |hosting| AnimeOnline::ExtractHosting.call hosting }
      .uniq
      .sort_by { |v| AnimeVideoDecorator::HOSTINGS_ORDER[v] || v }
      .map { |hosting| hosting.gsub(/^(?:.*\.)?([\w-]+)\.\w+$/, '\1').to_sym }
  end

  def hostings_text
    hostings.join(', ')
  end
end
