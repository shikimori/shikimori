FactoryGirl.define do
  factory :user_change do
    user
    approver nil
    model nil
    item_id nil
    column 'russian'
    value 'test1'
    prior 'test2'

    trait :with_user do
      user
    end

    trait :anime do
      model Anime.name
      item_id { FactoryGirl.create(:anime).id }
    end
  end
end
