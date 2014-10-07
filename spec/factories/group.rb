FactoryGirl.define do
  factory :group do
    sequence(:name) { |n| "club_#{n}" }
    join_policy :free_join

    association :owner, factory: :user
    description ''

    trait :free_join do
      join_policy :free_join
    end

    trait :owner_invite_join do
      join_policy :owner_invite_join
    end

    trait :linked_anime do
      after :build do |group|
        FactoryGirl.create :group_link, :anime, group: group
      end
    end

    trait :linked_manga do
      after :build do |group|
        FactoryGirl.create :group_link, :manga, group: group
      end
    end

    trait :linked_character do
      after :build do |group|
        FactoryGirl.create :group_link, :character, group: group
      end
    end

    after :build do |group|
      group.stub :generate_thread
      group.stub :sync_thread
      group.stub :join_owner
    end

    trait :with_thread do
      after :build do |group|
        group.unstub :generate_thread
      end
    end

    trait :with_owner_join do
      after :build do |group|
        group.unstub :join_owner
      end
    end
  end
end
