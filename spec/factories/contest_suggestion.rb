FactoryBot.define do
  factory :contest_suggestion do
    contest { nil }
    user
    item factory: :anime
  end
end
