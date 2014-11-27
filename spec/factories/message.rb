FactoryGirl.define do
  factory :message do
    association :from, factory: :user
    association :to, factory: :user

    kind MessageType::Private
  end
end
