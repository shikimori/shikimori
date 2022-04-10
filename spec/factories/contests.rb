FactoryBot.define do
  factory :contest do
    title_ru { 'Турнир' }
    title_en { 'Contest' }
    user { seed :user }

    member_type { Types::Contest::MemberType.values.sample }
    strategy_type { Types::Contest::StrategyType[:double_elimination] }
    user_vote_key { Types::Contest::UserVoteKey[:can_vote_1] }

    started_on { Time.zone.today }
    finished_on { nil }

    matches_per_round { 999 }
    match_duration { 1 }
    matches_interval { 1 }
    suggestions_per_user { 2 }

    Types::Contest::MemberType.values.each { |value| trait(value) { member_type { value } } }
    Types::Contest::StrategyType.values.each { |value| trait(value) { strategy_type { value } } }
    Types::Contest::UserVoteKey.values.each { |value| trait(value) { user_vote_key { value } } }

    Contest.aasm.states.map(&:name).each do |value|
      trait(value.to_sym) { state { value } }
    end
    trait :started_with_action do
      state { :started }
      after(:create) { |contest| Contest::Start.call contest }
    end

    trait :with_topics do
      after(:create) { |contest| contest.generate_topics %i[en ru] }
    end

    [3, 5, 6, 8, 19].each do |members|
      trait "with_#{members}_members".to_sym do
        after(:create) do |contest|
          members.times { contest.members << FactoryBot.create(contest.member_type) }
        end
      end
    end
  end
end
