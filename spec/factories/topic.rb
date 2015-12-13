FactoryGirl.define do
  factory :topic do
    user { seed :user }
    section { seed :offtopic_section }
    sequence(:title) { |n| "topic_#{n}" }
    sequence(:text) { |n| "topic_text_#{n}" }

    factory :review_comment, class: 'ReviewComment' do
      type 'ReviewComment'
      section { seed :reviews_section }
    end

    factory :cosplay_comment, class: 'CosplayComment' do
      type 'CosplayComment'
    end

    factory :contest_comment, class: 'ContestComment' do
      type 'ContestComment'
    end

    factory :club_comment, class: 'GroupComment' do
      type 'GroupComment'
    end

    factory :anime_news, class: 'AnimeNews' do
      type 'AnimeNews'
      section { seed :anime_section }
    end

    after :build do |topic|
      topic.class.skip_callback :create, :before, :check_antispam
    end
  end
end
