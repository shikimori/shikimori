module Types
  module RelatedAniManga
    RELATION_KINDS = %i[
      adaptation
      alternative_setting
      alternative_version
      character
      full_story
      other
      parent_story
      prequel
      sequel
      side_story
      spin_off
      summary
    ]
    RelationKind = Types::Strict::Symbol
      .constructor(&:to_sym)
      .enum(*RELATION_KINDS)
  end
end
