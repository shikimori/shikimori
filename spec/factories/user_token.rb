FactoryGirl.define do
  factory :user_token do
    user
    provider 'facebook'
  end
end
