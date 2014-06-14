FactoryGirl.define do
  factory :manga_chapter do
    name 'test chapter'
    url 'http://test.com'

    after :build do |chapter|
      chapter.manga = build_stubbed(:manga) unless chapter.manga_id
    end
  end
end
