# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :club_ban do
    club { nil }
    user { nil }
  end
end
