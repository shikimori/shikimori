module Types
  module Video
    HOSTINGS = %i[
      youtube youtube_shorts rutube rutube_shorts
      vk ok coub rutube vimeo sibnet yandex
      streamable smotret_anime myvi youmite viuly mediafile
    ]
    # dailymotion twitch
    KINDS = %i[
      pv
      character_trailer
      cm
      op
      ed
      op_ed_clip
      clip
      other
      episode_preview
    ]

    Hosting = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*HOSTINGS)
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)

    State = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(:uploaded, :confirmed, :deleted)
  end
end
