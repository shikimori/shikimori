FactoryBot.define do
  factory :related_manga do
    source { nil }
    anime { nil }
    manga { nil }
    relation_kind { Types::RelatedAniManga::RelationKind[:other] }
  end
end
