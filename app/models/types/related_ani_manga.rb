module Types
  module RelatedAniManga
    RELATION_KINDS = MalParser::Entry::Anime::RELATED.values
    RelationKind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*RELATION_KINDS)
  end
end
