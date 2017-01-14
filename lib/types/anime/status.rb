module Types
  module Anime
    Status = Types::Strict::Symbol
      .constructor(-> (val) { val.to_sym })
      .enum(
        *%i(
          anons
          ongoing
          released
          planned
          latest
        )
      )
  end
end
