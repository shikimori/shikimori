FactoryBot.define do
  factory :poll do
    user { seed :user }
    state { :pending }
    name { 'new poll' }
    text { 'poll text' }
    width { Types::Poll::Width[:limited] }

    # Poll.aasm.states.map(&:name).each do |value|
    #   trait(value.to_sym) { state { value } }
    # end

    trait :with_variants do
      after :build do |model|
        FactoryBot.create :poll_variant, poll: model
        FactoryBot.create :poll_variant, poll: model
      end
    end
  end
end
