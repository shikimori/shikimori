FactoryGirl.define do
  factory :message do
    from { seed :user }
    to { seed :user }

    read false

    kind MessageType::Private
    body 'test'

    trait :private do
      kind MessageType::Private
    end

    trait :notification do
      kind MessageType::Notification
    end

    trait :profile_commented do
      kind MessageType::ProfileCommented
    end

    trait :news do
      kind MessageType::SiteNews
    end
  end
end
