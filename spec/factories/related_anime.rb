FactoryGirl.define do
  factory :related_anime do
    source nil
    anime nil
    manga nil
    relation 'test'
  end
end
