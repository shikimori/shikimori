FactoryBot.define do
  factory :summary do
    user { seed :user }
    anime { nil }
    manga { nil }
    body { 'MyText' }
    tone { Types::Summary::Tone[:neutral] }
    is_written_before_release { false }

    Types::Summary::Tone.values.each do |value|
      trait(value) { tone { value } }
    end
  end
end
