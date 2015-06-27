module AniMangasCollectionHelper
  # разбивка по типам
  def kinds_with_colors
    [
      { kind: 'tv', color: 'blue' },
      { kind: 'movie', color: 'orange' },
      { kind: 'OVA/ONA', color: 'green' },
      { kind: 'special', color: 'purple' },
      { kind: 'music', color: 'skyblue' },

      { kind: 'manga', color: 'blue' },
      { kind: 'manhwa', color: 'green' },
      { kind: 'novel', color: 'purple' },
      { kind: 'manhua', color: 'orange' },
      { kind: 'one_shot', color: 'skyblue' },
      { kind: 'doujin', color: 'pink' }
    ]
  end
end
