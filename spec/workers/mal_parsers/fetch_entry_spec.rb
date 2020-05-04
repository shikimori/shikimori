describe MalParsers::FetchEntry do
  let(:worker) { described_class.new }

  include_context :timecop

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

      allow(DbImport::Anime).to receive(:call).with import_data
    end
    let(:anime_data) do
      { kind: 'Movie', name: 'Koe no Katachi' }
    end
    let(:characters_data) do
      {
        characters: [{ id: 143_628, roles: %w[Main] }],
        staff: [{ id: 33_365, roles: %w[Director] }]
      }
    end
    let(:recommendations_data) do
      [{ id: 28_735, type: :anime }]
    end
    let(:import_data) do
      anime_data.merge(
        characters: characters_data,
        recommendations: recommendations_data
      )
    end
    subject { worker.perform id, type }

    describe 'successfull import' do
      before { subject }
      it do
        expect(DbImport::Anime).to have_received(:call).with import_data
      end
    end

    describe 'InvalidIdError' do
      before do
        allow(DbImport::Anime)
          .to receive(:call)
          .and_raise InvalidIdError.new(id)
      end

      context 'present entry' do
        let!(:entry) { create type, id: id, mal_id: id }
        before { subject }
        it do
          expect(entry.reload.mal_id).to eq nil
          expect(entry.reload.imported_at.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'new entry' do
        it { expect { subject }.to raise_error InvalidIdError }
      end
    end
  end
end
