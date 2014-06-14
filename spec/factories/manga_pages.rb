FactoryGirl.define do
  factory :manga_page do
    url 'http://test.com/page1'
    number 1
    chapter nil

    after :build do |page|
      page.chapter = build_stubbed(:manga_chapter) unless page.manga_chapter_id
    end
  end
end
