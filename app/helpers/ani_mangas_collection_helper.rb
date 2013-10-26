module AniMangasCollectionHelper
  # разбивка по типам
  def kinds_with_colors
    [
      { kind: 'TV', color: 'blue' },
      { kind: 'Movie', color: 'orange' },
      { kind: 'OVA/ONA', color: 'green' },
      { kind: 'Special', color: 'purple' },
      { kind: 'Music', color: 'skyblue' }
    ]
  end
end
