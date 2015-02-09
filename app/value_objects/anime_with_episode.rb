class AnimeWithEpisode < SimpleDelegator
  attr_reader :episode

  def initialize entry, episode
    super entry
    @episode = episode
  end

  def video_types
    if episode.subtitles? && episode.fandub?
      'Озвучка и субтитры'
    elsif episode.subtitles?
      'Субтитры'
    elsif episode.fandub?
      'Озвучка'
    end
  end
end
