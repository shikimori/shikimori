FactoryBot.define do
  factory :topic do
    user { seed :user }
    forum { seed :offtopic_forum }
    sequence(:title) { |n| "topic_#{n}" }
    sequence(:body) { |n| "topic_text_#{n}" }
    type { Topic.name }
    tags { [] }

    locale { 'ru' }
    is_pinned { false }

    after :build do |model|
      stub_method model, :antispam_checks
      stub_method model, :create_viewing
    end

    trait :with_antispam do
      after(:build) { |model| unstub_method model, :antispam_checks }
    end
    trait :with_create_viewing do
      after(:build) { |model| unstub_method model, :create_viewing }
    end

    factory :forum_topic do
      type { 'Topic' }
    end

    factory :anime_topic, class: 'Topics::EntryTopics::AnimeTopic' do
      type { 'Topics::EntryTopics::AnimeTopic' }
      forum { seed :animanga_forum }
      generated { true }
    end

    factory :manga_topic, class: 'Topics::EntryTopics::MangaTopic' do
      type { 'Topics::EntryTopics::MangaTopic' }
      forum { seed :animanga_forum }
      generated { true }
    end

    factory :ranobe_topic, class: 'Topics::EntryTopics::RanobeTopic' do
      type { 'Topics::EntryTopics::RanobeTopic' }
      forum { seed :animanga_forum }
      generated { true }
    end

    factory :character_topic, class: 'Topics::EntryTopics::CharacterTopic' do
      type { 'Topics::EntryTopics::CharacterTopic' }
      forum { seed :animanga_forum }
      generated { true }
    end

    factory :person_topic, class: 'Topics::EntryTopics::PersonTopic' do
      type { 'Topics::EntryTopics::PersonTopic' }
      forum { seed :animanga_forum }
      generated { true }
    end

    factory :critique_topic, class: 'Topics::EntryTopics::CritiqueTopic' do
      type { 'Topics::EntryTopics::CritiqueTopic' }
      forum { seed :critiques_forum }
      generated { true }
    end

    factory :cosplay_gallery_topic, class: 'Topics::EntryTopics::CosplayGalleryTopic' do
      type { 'Topics::EntryTopics::CosplayGalleryTopic' }
      generated { true }
    end

    factory :contest_topic, class: 'Topics::EntryTopics::ContestTopic' do
      type { 'Topics::EntryTopics::ContestTopic' }
      generated { true }
    end

    factory :contest_status_topic, class: 'Topics::NewsTopics::ContestStatusTopic' do
      type { 'Topics::NewsTopics::ContestStatusTopic' }
      generated { true }
      Types::Topic::ContestStatusTopic::Action.values.each do |value|
        trait(value) { state { value } }
      end
    end

    factory :club_topic, class: 'Topics::EntryTopics::ClubTopic' do
      type { 'Topics::EntryTopics::ClubTopic' }
      generated { true }
    end

    factory :club_user_topic, class: 'Topics::ClubUserTopic' do
      type { 'Topics::ClubUserTopic' }
      generated { false }
    end

    factory :club_page_topic, class: 'Topics::EntryTopics::ClubPageTopic' do
      type { 'Topics::EntryTopics::ClubPageTopic' }
      generated { true }
    end

    factory :collection_topic, class: 'Topics::EntryTopics::CollectionTopic' do
      type { 'Topics::EntryTopics::CollectionTopic' }
      generated { true }
    end

    factory :article_topic, class: 'Topics::EntryTopics::ArticleTopic' do
      type { 'Topics::EntryTopics::ArticleTopic' }
      generated { true }
    end

    factory :news_topic, class: 'Topics::NewsTopic' do
      type { 'Topics::NewsTopic' }
      forum { seed :news_forum }

      trait :anime_anons do
        linked { create :anime }
        forum { seed :animanga_forum }
        action { :anons }
        generated { true }
      end
    end

    trait :offtopic do
      id { Topic::TOPIC_IDS[:offtopic][:ru] }
      title { 'offtopic' }
      body { 'offtopic' }
      created_at { 1.day.ago }
      updated_at { 1.day.ago }
    end
    trait :site_rules do
      id { Topic::TOPIC_IDS[:site_rules][:ru] }
      title { 'site rules' }
      body { 'site rules' }
      created_at { 2.days.ago }
      updated_at { 2.days.ago }
    end
    trait :description_of_genres do
      id { Topic::TOPIC_IDS[:description_of_genres][:ru] }
      title { 'description of genres' }
      body { 'description of genres' }
      created_at { 4.days.ago }
      updated_at { 4.days.ago }
    end
    trait :ideas_and_suggestions do
      id { Topic::TOPIC_IDS[:ideas_and_suggestions][:ru] }
      title { 'ideas and suggestions' }
      body { 'ideas and suggestions' }
      created_at { 5.days.ago }
      updated_at { 5.days.ago }
    end
    trait :site_problems do
      id { Topic::TOPIC_IDS[:site_problems][:ru] }
      title { 'site problems' }
      body { 'site problems' }
      created_at { 6.days.ago }
      updated_at { 6.days.ago }
    end
    trait :contests_proposals do
      id { Topic::TOPIC_IDS[:contests_proposals][:ru] }
      title { 'contests_proposals' }
      body { 'contests_proposals' }
      created_at { 7.days.ago }
      updated_at { 7.days.ago }
    end
    trait :socials do
      id { Topic::TOPIC_IDS[:socials][:ru] }
      title { 'socials' }
      body { 'socials' }
      created_at { 8.days.ago }
      updated_at { 8.days.ago }
    end

    factory :offtopic_topic, traits: [:offtopic]
    factory :site_rules_topic, traits: [:site_rules]
    factory :description_of_genres_topic, traits: [:description_of_genres]
    factory :ideas_and_suggestions_topic, traits: [:ideas_and_suggestions]
    factory :site_problems_topic, traits: [:site_problems]
    factory :contests_proposals_topic, traits: [:contests_proposals]
    factory :socials_topic, traits: [:socials]
  end
end
