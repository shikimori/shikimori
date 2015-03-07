module AniMangasCollectionHelper
  # разбивка по типам
  def kinds_with_colors
    [
      { kind: 'TV', color: 'blue' },
      { kind: 'Movie', color: 'orange' },
      { kind: 'OVA/ONA', color: 'green' },
      { kind: 'Special', color: 'purple' },
      { kind: 'Music', color: 'skyblue' },

      { kind: 'Manga', color: 'blue' },
      { kind: 'Manhwa', color: 'green' },
      { kind: 'Novel', color: 'purple' },
      { kind: 'Manhua', color: 'orange' },
      { kind: 'One-Shot', color: 'skyblue' },
      { kind: 'Doujin', color: 'pink' }
    ]
  end
end
