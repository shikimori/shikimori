class AnimeWithEpisode < SimpleDelegator
  attr_reader :episode

  def initialize entry, episode
    super entry
    @episode = episode
  end
end
