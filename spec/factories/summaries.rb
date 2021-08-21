FactoryBot.define do
  factory :summary do
    user { seed :user }
    anime { nil }
    manga { nil }
    body { 'a' * Summary::MIN_BODY_SIZE }
    tone { Types::Summary::Tone[:neutral] }
    is_written_before_release { false }

    comments_count { 0 }
    cached_votes_up { 0 }
    cached_votes_down { 0 }

    Types::Summary::Tone.values.each do |value|
      trait(value) { tone { value } }
    end
  end
end
