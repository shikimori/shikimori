FactoryGirl.define do
  factory :anime_episode_news, :class => :anime_news do
    action AnimeHistoryAction::Episode
    value "1"
    sequence(:title) { |n| "anime news #{n}" }
    sequence(:text) { |n| "anime news #{n}" }
  end
end
