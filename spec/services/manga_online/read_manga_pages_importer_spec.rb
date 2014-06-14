require 'spec_helper'

describe MangaOnline::ReadMangaPagesImporter do
  let(:importer) { MangaOnline::ReadMangaPagesImporter.new pages }

  describe :save do
    subject { importer.save }

    context :blank do
      let(:pages) { nil }
      it { should be_blank }
    end

    context :pages do
      let(:chapter) { create :manga_chapter }
      let(:page1) { build :manga_page, chapter: chapter, url: 'http://1.ru', number: 1 }
      let(:page2) { build :manga_page, chapter: chapter, url: 'http://2.ru', number: 2 }
      let(:pages) { [page1, page2] }
      before { create :manga_page, chapter: chapter, url: 'http://1.ru', number: 1 }

      specify { subject.first.url.should eq page1.url }
      specify { subject.second.url.should eq page2.url }
      it { expect { subject }.to change(MangaPage, :count).by 1 }
    end
  end
end
