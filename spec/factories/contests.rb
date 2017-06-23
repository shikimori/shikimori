FactoryGirl.define do
  factory :contest do
    title_ru 'Турнир'
    title_en 'Contest'
    user { seed :user }

    member_type { Types::Contest::MemberType.values.sample }
    strategy_type Types::Contest::StrategyType[:double_elimination]
    user_vote_key Types::Contest::UserVoteKey[:can_vote_1]

    started_on Time.zone.today
    finished_on nil

    matches_per_round 999
    match_duration 1
    matches_interval 1
    suggestions_per_user 2

    trait :anime do
      member_type :anime
    end

    trait :character do
      member_type :character
    end

    Contest.state_machine.states.map(&:value).each do |contest_state|
      trait(contest_state.to_sym) { state contest_state }
    end

    trait :with_topics do
      after(:create) { |contest| contest.generate_topics %i[en ru] }
    end

    [3, 5, 6, 8, 19].each do |members|
      trait "with_#{members}_members".to_sym do
        after(:create) do |contest|
          members.times { contest.members << FactoryGirl.create(contest.member_type) }
        end
      end
    end
  end
end
