FactoryGirl.define do
  factory :list_import do
    user { seed :user }
    list nil
  end
end
