FactoryBot.define do
  factory :favourite do
    linked { nil }
    user { seed :user }
    kind { Types::Favourite::Kind[:common] }

    Types::Favourite::Kind.values.each do |v|
      trait(v.to_sym) { kind { v } }
    end
  end
end
