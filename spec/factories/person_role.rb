FactoryGirl.define do
  factory :person_role do
    anime nil
    manga nil
    character nil
    person nil

    trait :seyu_role do
      anime_role
      character
      person
      role 'Japanese'
    end

    trait :anime_role do
      anime
      role 'Main'
    end

    trait :manga_role do
      manga
      role 'Main'
    end
  end
end
