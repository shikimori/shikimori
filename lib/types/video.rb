module Types
  module Video
    HOSTINGS = %i[
      youtube vk ok coub rutube vimeo sibnet yandex
      streamable smotret_anime myvi youmite viuly stormo
      mediafile
    ]
    # dailymotion twitch
    KINDS = %i[
      pv op ed other
    ]

    Hosting = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*HOSTINGS)
    Kind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*KINDS)
  end
end
