describe MangaPage, :type => :model do
  it { should belong_to :chapter }

  it { should validate_presence_of :url }
  it { should validate_presence_of :number }

  describe 'page' do
    let(:manga) { build :manga, id: 251 }
    let(:chapter) { build :manga_chapter, id: 10, manga: manga, name: '1 - 1 name (рус)' }
    subject { build :manga_page, chapter: chapter, number: 1 }
    its(:chapter_name) { should eq '1 - 1 name (rus)' }
    its(:manga_id_mod) { should eq 1 }
  end
end
