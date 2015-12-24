FactoryGirl.define do
  factory :topic do
    user { seed :user }
    forum { seed :offtopic_forum }
    sequence(:title) { |n| "topic_#{n}" }
    sequence(:text) { |n| "topic_text_#{n}" }

    factory :review_comment, class: 'ReviewComment' do
      type 'ReviewComment'
      forum { seed :reviews_forum }
    end

    factory :cosplay_comment, class: 'CosplayComment' do
      type 'CosplayComment'
    end

    factory :contest_comment, class: 'ContestComment' do
      type 'ContestComment'
    end

    factory :club_comment, class: 'ClubComment' do
      type 'ClubComment'
    end

    factory :anime_news, class: 'AnimeNews' do
      type 'AnimeNews'
      forum { seed :animanga_forum }
    end

    after :build do |topic|
      topic.class.skip_callback :create, :before, :check_antispam
    end
  end
end
