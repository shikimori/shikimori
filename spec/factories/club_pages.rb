FactoryBot.define do
  factory :club_page do
    club { nil }
    user { seed :user }
    parent_page { nil }
    name { 'MyString' }
    text { 'MyText' }
  end
end
