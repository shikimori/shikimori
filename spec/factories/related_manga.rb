FactoryGirl.define do
  factory :related_manga do
    source nil
    anime nil
    manga nil
    relation 'test'
  end
end
