module Types
  module Video
    HOSTINGS = %i[
      youtube vk ok coub rutube vimeo sibnet yandex
      streamable smotret_anime myvi youmite viuly stormo
      mediafile
    ]
    # dailymotion twitch

    Hosting = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*HOSTINGS)
  end
end
