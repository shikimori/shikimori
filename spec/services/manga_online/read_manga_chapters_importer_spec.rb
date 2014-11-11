describe MangaOnline::ReadMangaChaptersImporter do
  let(:importer) { MangaOnline::ReadMangaChaptersImporter.new(chapters) }

  describe :save do
    subject { importer.save }

    context :blank do
      let(:chapters) { nil }
      it { should be_blank }
    end

    context :chapters do
      let(:manga) { create :manga }
      let(:chapter1) { build :manga_chapter, manga: manga, url: 'http://1.ru' }
      let(:chapter2) { build :manga_chapter, manga: manga, url: 'http://2.ru' }
      let(:chapters) { [chapter1, chapter2] }
      before { create :manga_chapter, manga: manga, url: 'http://1.ru' }

      specify { subject.first.url.should eq chapter1.url }
      specify { subject.second.url.should eq chapter2.url }
      it { expect { subject }.to change(MangaChapter, :count).by 1 }
    end
  end
end
