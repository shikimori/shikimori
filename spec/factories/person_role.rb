FactoryBot.define do
  factory :person_role do
    anime { nil }
    manga { nil }
    character { nil }
    person { nil }

    trait :seyu_role do
      anime_role
      character
      person
      roles { %w[Japanese] }
    end

    trait :anime_role do
      anime
      roles { %w[Main] }
    end

    trait :manga_role do
      manga
      roles { %w[Main] }
    end

    trait :staff_role do
      person
      roles { %w[Main] }
    end

    trait :character_role do
      character
      roles { %w[Main] }
    end
  end
end
