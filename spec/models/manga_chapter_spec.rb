describe MangaChapter, :type => :model do
  it { should belong_to :manga }
  it { should have_many :pages }

  it { should validate_presence_of :name }
  it { should validate_presence_of :url }
end
