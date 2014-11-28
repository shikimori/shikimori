FactoryGirl.define do
  factory :message do
    association :from, factory: :user
    association :to, factory: :user

    kind MessageType::Private
    body 'test'

    trait :private do
      kind MessageType::Private
    end

    trait :notification do
      kind MessageType::Notification
    end
  end
end
