FactoryGirl.define do
  factory :anime_video do
    url  'http://test.com/video/1'
    kind  AnimeVideo.kind.values.first
    author  nil

    after :build do |v|
      v.anime = FactoryGirl.build_stubbed(:anime)
    end
  end
end
