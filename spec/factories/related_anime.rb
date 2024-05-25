FactoryBot.define do
  factory :related_anime do
    source { nil }
    anime { nil }
    manga { nil }
    relation { 'Other' }
    relation_kind { Types::RelatedAniManga::RelationKind[:other] }
  end
end
