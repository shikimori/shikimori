FactoryGirl.define do
  factory :achievement do
    neko_id 'test'
    level 1
    progress 0
    user
  end
end
