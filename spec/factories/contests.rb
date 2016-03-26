FactoryGirl.define do
  factory :contest do
    title "MyString"
    user { seed :user }

    member_type { [:anime, :character].sample }
    strategy_type :double_elimination

    started_on Date.today

    matches_per_round 999
    match_duration 1
    matches_interval 1
    user_vote_key 'can_vote_1'
    suggestions_per_user 2

    trait :anime do
      member_type :anime
    end

    trait :character do
      member_type :character
    end

    trait :proposing do
      state 'proposing'
    end

    trait :started do
      state 'started'
    end

    trait :finished do
      state 'finished'
    end

    after :build do |contest|
      contest.stub :update_permalink
      contest.stub :sync_topic
    end

    trait :with_topic do
      after :build do |contest|
        contest.generate_topic
      end
    end

    [3,5,6,8,19].each do |members|
      trait "with_#{members}_members".to_sym do
        after(:create) do |contest|
          members.times { contest.members << FactoryGirl.create(contest.member_type) }
        end
      end
    end
  end
end
