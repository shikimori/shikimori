FactoryGirl.define do
  factory :topic do
    user { seed :user }
    forum { seed :offtopic_forum }
    sequence(:title) { |n| "topic_#{n}" }
    sequence(:body) { |n| "topic_text_#{n}" }

    factory :review_topic, class: 'Topics::EntryTopics::ReviewTopic' do
      type 'Topics::EntryTopics::ReviewTopic'
      forum { seed :reviews_forum }
    end

    factory :cosplay_gallery_topic, class: 'Topics::EntryTopics::CosplayGalleryTopic' do
      type 'Topics::EntryTopics::CosplayGalleryTopic'
    end

    factory :contest_topic, class: 'Topics::EntryTopics::ContestTopic' do
      type 'Topics::EntryTopics::ContestTopic'
    end

    factory :club_topic, class: 'Topics::EntryTopics::ClubTopic' do
      type 'Topics::EntryTopics::ClubTopic'
    end

    factory :news_topic, class: 'Topics::NewsTopic' do
      type 'Topics::NewsTopic'
      forum { seed :animanga_forum }
    end

    after :build do |topic|
      topic.class.skip_callback :create, :before, :check_antispam
    end
  end
end
