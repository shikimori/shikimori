class LicensorsRepository
  include Singleton

  def anime
    @anime ||= fetch(Anime, 5)
  end

  def manga
    @manga ||= fetch(Manga, 5)
  end

  def ranobe
    @ranobe ||= fetch(Ranobe, 0)
  end

  def reset
    @anime = nil
    @manga = nil
    @ranobe = nil
    true
  end

private

  def fetch scope, group_limit
    scope
      .where.not(licensor: '')
      .group(:licensor)
      .count
      .group_by { |_licensor, count| count >= group_limit ? 0 : 1 }
      .sort_by(&:first)
      .map do |_grouping, licensors|
        licensors.map { |licensor, _count| licensor }.sort
      end
  end
end
