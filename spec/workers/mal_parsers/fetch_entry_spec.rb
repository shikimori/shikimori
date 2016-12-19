describe MalParsers::FetchEntry do
  let(:worker) { MalParsers::FetchEntry.new }

  describe '#perform' do
    let(:id) { 28_851 }
    let(:type) { 'anime' }

    before do
      allow(MalParser::Entry::Anime)
        .to receive(:call)
        .with(id)
        .and_return(anime_data)
      allow(MalParser::Entry::Characters)
        .to receive(:call)
        .with(id, type)
        .and_return(characters_data)
      allow(MalParser::Entry::Recommendations)
        .to receive(:call)
        .with(id, type)
        .and_return(recommendations_data)

      allow(Imports::Anime).to receive(:call).with import_data
    end
    let(:anime_data) do
      { kind: 'Movie', name: 'Koe no Katachi' }
    end
    let(:characters_data) do
      {
        characters: [{ id: 143_628, role: 'Main' }],
        staff: [{ id: 33_365, role: 'Director' }]
      }
    end
    let(:recommendations_data) do
      [{ id: 28_735, type: :anime }]
    end
    let(:import_data) do
      {
        data: anime_data,
        characters: characters_data,
        recommendations: recommendations_data
      }
    end
    subject! { worker.perform id, type }

    it do
      expect(Imports::Anime).to have_received(:call).with import_data
    end
  end
end
