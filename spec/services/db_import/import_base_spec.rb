describe DbImport::ImportBase do
  class DbImport::Test < DbImport::ImportBase # rubocop:disable ConstantDefinitionInBlock
    SPECIAL_FIELDS = %i[japanese]
    IGNORED_FIELDS = %i[zzz]

    def klass
      Anime
    end

    def assign_japanese japanese
      entry.japanese = japanese
    end

    # def schedule_fetch_authorized
    #   MalParsers::FetchEntryAuthorized.perform_async(
    #     entry.mal_id,
    #     entry.class.name
    #   )
    # end
  end
  let(:service) { DbImport::Test.new data }
  let(:data) do
    {
      id: id,
      name: 'Zzzz',
      english: 'Xxxxx',
      japanese: 'Kkkkkk',
      zzz: 'xxx'
    }
  end
  let(:id) { 9_876_543 }

  include_context :timecop

  # before { allow(MalParsers::FetchEntryAuthorized).to receive :perform_async }
  subject(:entry) { service.call }

  it do
    expect(entry).to be_persisted
    expect(entry).to be_valid
    expect(entry.mal_id).to eq data[:id]
    expect(entry.imported_at).to eq Time.zone.now
    expect(entry).to have_attributes data.except(:zzz)
  end

  describe 'create' do
    it do
      expect { subject }.to change(Anime, :count).by 1
      expect(entry).to be_persisted
      # expect(MalParsers::FetchEntryAuthorized)
      #   .to have_received(:perform_async)
      #   .with(entry.mal_id, entry.class.name)
    end

    context 'banned id' do
      let(:id) { 111111111 }
      it { expect { subject }.to_not change Anime, :count }
      it do
        expect(entry).to be_nil
        # expect(MalParsers::FetchEntryAuthorized)
        #   .to_not have_received(:perform_async)
      end
    end
  end

  describe 'update' do
    let!(:anime) { create :anime, id: data[:id], name: 'q', mal_id: data[:id] }

    it do
      expect { subject }.to_not change Anime, :count
      expect(entry).to be_persisted
      expect(entry).to have_attributes(data.except(:zzz))
      # expect(MalParsers::FetchEntryAuthorized)
      #   .to_not have_received(:perform_async)
    end

    context 'banned id' do
      let(:id) { 111111111 }
      it { expect(entry).to be_nil }
    end

    describe 'blank special field' do
      let!(:anime) do
        create :anime, id: data[:id], japanese: 'q', desynced: %w[name]
      end
      before { data[:japanese] = nil }
      it { expect(entry.japanese).to eq 'q' }
    end

    describe 'desynced data field' do
      let!(:anime) do
        create :anime, id: data[:id], name: 'q', desynced: %w[name]
      end
      it { expect(entry.name).to eq 'q' }
    end

    describe 'desynced special field' do
      let!(:anime) do
        create :anime, id: data[:id], japanese: 'f', desynced: %w[japanese]
      end
      it { expect(entry.japanese).to eq 'f' }
    end
  end
end
