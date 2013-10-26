FactoryGirl.define do
  factory :contest do
    title "MyString"
    user
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

    after(:build) do |contest|
      contest.stub :create_thread
      contest.stub :update_permalink
      contest.stub :sync_thread
    end

    trait :with_thread do
      after(:build) do |contest|
        contest.unstub :create_thread
      end
    end

    [3,5,6,8,19].each do |members|
      factory "contest_with_#{members}_members" do
        after(:create) do |contest|
          members.times { contest.members << FactoryGirl.create(contest.member_type) }
        end
      end
    end
  end
end
