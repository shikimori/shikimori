FactoryGirl.define do
  factory :topic do
    user { seed :user }
    forum { seed :offtopic_forum }
    sequence(:title) { |n| "topic_#{n}" }
    sequence(:body) { |n| "topic_text_#{n}" }
    type { Topic.name }

    locale 'ru'

    factory :forum_topic do
      type 'Topic'
    end

    factory :anime_topic, class: 'Topics::EntryTopics::AnimeTopic' do
      type 'Topics::EntryTopics::AnimeTopic'
      forum { seed :animanga_forum }
      generated true
    end

    factory :manga_topic, class: 'Topics::EntryTopics::MangaTopic' do
      type 'Topics::EntryTopics::MangaTopic'
      forum { seed :animanga_forum }
      generated true
    end

    factory :character_topic, class: 'Topics::EntryTopics::CharacterTopic' do
      type 'Topics::EntryTopics::CharacterTopic'
      forum { seed :animanga_forum }
      generated true
    end

    factory :person_topic, class: 'Topics::EntryTopics::PersonTopic' do
      type 'Topics::EntryTopics::PersonTopic'
      forum { seed :animanga_forum }
      generated true
    end

    factory :review_topic, class: 'Topics::EntryTopics::ReviewTopic' do
      type 'Topics::EntryTopics::ReviewTopic'
      forum { seed :reviews_forum }
      generated true
    end

    factory :cosplay_gallery_topic, class: 'Topics::EntryTopics::CosplayGalleryTopic' do
      type 'Topics::EntryTopics::CosplayGalleryTopic'
      generated true
    end

    factory :contest_topic, class: 'Topics::EntryTopics::ContestTopic' do
      type 'Topics::EntryTopics::ContestTopic'
      generated true
    end

    factory :club_topic, class: 'Topics::EntryTopics::ClubTopic' do
      type 'Topics::EntryTopics::ClubTopic'
      generated true
    end

    factory :news_topic, class: 'Topics::NewsTopic' do
      type 'Topics::NewsTopic'
      forum { seed :animanga_forum }

      trait :anime_anons do
        linked { create :anime }
        action :anons
        generated true
      end
    end

    after :build do |model|
      stub_method model, :check_antispam
    end

    trait :offtopic do
      id Topic::TOPIC_IDS[Forum::OFFTOPIC_ID][:offtopic][:ru]
      title 'offtopic'
      body 'offtopic'
      created_at { 1.day.ago }
      updated_at { 1.day.ago }
      forum { seed :offtopic_forum }
    end
    trait :site_rules do
      id Topic::TOPIC_IDS[Forum::OFFTOPIC_ID][:site_rules][:ru]
      title 'site rules'
      body 'site rules'
      created_at { 2.days.ago }
      updated_at { 2.days.ago }
      forum { seed :offtopic_forum }
    end
    trait :faq do
      id Topic::TOPIC_IDS[Forum::OFFTOPIC_ID][:faq][:ru]
      title 'faq'
      body 'faq'
      created_at { 3.days.ago }
      updated_at { 3.days.ago }
      forum { seed :offtopic_forum }
    end
    trait :description_of_genres do
      id Topic::TOPIC_IDS[Forum::OFFTOPIC_ID][:description_of_genres][:ru]
      title 'description of genres'
      body 'description of genres'
      created_at { 4.days.ago }
      updated_at { 4.days.ago }
      forum { seed :offtopic_forum }
    end
    trait :ideas_and_suggestions do
      id Topic::TOPIC_IDS[Forum::OFFTOPIC_ID][:ideas_and_suggestions][:ru]
      title 'ideas and suggestions'
      body 'ideas and suggestions'
      created_at { 5.days.ago }
      updated_at { 5.days.ago }
      forum { seed :offtopic_forum }
    end
    trait :site_problems do
      id Topic::TOPIC_IDS[Forum::OFFTOPIC_ID][:site_problems][:ru]
      title 'site problems'
      body 'site problems'
      created_at { 6.days.ago }
      updated_at { 6.days.ago }
      forum { seed :offtopic_forum }
    end

    factory :offtopic_topic, traits: [:offtopic]
    factory :site_rules_topic, traits: [:site_rules]
    factory :faq_topic, traits: [:faq]
    factory :description_of_genres_topic, traits: [:description_of_genres]
    factory :ideas_and_suggestions_topic, traits: [:ideas_and_suggestions]
    factory :site_problems_topic, traits: [:site_problems]
  end
end
