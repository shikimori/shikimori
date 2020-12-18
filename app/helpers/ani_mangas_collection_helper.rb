module AniMangasCollectionHelper
  # разбивка по типам
  def kinds_with_colors
    [
      { kind: 'tv', color: 'red' },
      { kind: 'movie', color: 'orange' },
      { kind: 'OVA/ONA', color: 'green' },
      { kind: 'special', color: 'purple' },
      { kind: 'music', color: 'skyblue' },

      { kind: 'manga', color: 'blue' },
      { kind: 'manhwa', color: 'purple' },
      { kind: 'light_novel', color: 'green' },
      { kind: 'novel', color: 'green' },
      { kind: 'manhua', color: 'orange' },
      { kind: 'one_shot', color: 'skyblue' },
      { kind: 'doujin', color: 'pink' }
    ]
  end
end
