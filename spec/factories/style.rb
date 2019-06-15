FactoryBot.define do
  factory :style do
    owner { seed :user }
    name { '' }
    css { '' }
    compiled_css { nil }
    imports { [] }
  end
end
