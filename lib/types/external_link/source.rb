module Types
  module ExternalLink
    Source = Types::Strict::String.enum(
      *%w(
        myanimelist
        shikimori
      )
    )
  end
end
