FactoryGirl.define do
  factory :style do
    name 'test style'
    owner { seed :user }
    css 'body {}'
  end
end
