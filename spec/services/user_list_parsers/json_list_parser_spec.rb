describe UserListParsers::JsonListParser do
  let(:parser) { UserListParsers::JsonListParser.new klass }
  subject { parser.parse json }

  context 'anime' do
    let(:klass) { Anime }
    let(:json) { "[{\"id\":1,\"status\":2,\"episodes\":3,\"rewatches\":4,\"score\":5.0,\"name\":\"anime name\"}]" }
    it { should eq [{id: 1, status: 2, episodes: 3, rewatches: 4, score: 5.0}] }
  end

  context 'manga' do
    let(:klass) { Manga }
    let(:json) { "[{\"id\":1,\"status\":2,\"volumes\":3,\"chapters\":4,\"rewatches\":5,\"score\":6.0,\"name\":\"anime name\"}]" }
    it { should eq [{id: 1, status: 2, volumes: 3, chapters: 4, rewatches: 5, score: 6.0}] }
  end
end
