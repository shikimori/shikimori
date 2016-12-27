describe Import::ImportBase do
  class Import::Test < Import::ImportBase
    SPECIAL_FIELDS = %i(japanese)
    IGNORED_FIELDS = %i(zzz)

    def klass
      Anime
    end

    def assign_japanese japanese
      entry.japanese = japanese
    end
  end
  let(:service) { Import::Test.new data }
  let(:data) do
    {
      id: 9_876_543,
      name: 'Zzzz',
      english: 'Xxxxx',
      japanese: 'Kkkkkk',
      zzz: 'xxx'
    }
  end

  before { Timecop.freeze }
  after { Timecop.return }

  subject(:entry) { service.call }

  describe '#call' do
    it do
      expect(entry).to be_persisted
      expect(entry).to be_valid
      expect(entry.imported_at).to eq Time.zone.now
      expect(entry).to have_attributes data.except(:zzz)
    end

    describe 'create' do
      it do
        expect { subject }.to change(Anime, :count).by 1
        expect(entry).to be_persisted
      end
    end

    describe 'update' do
      let!(:anime) { create :anime, id: data[:id], name: 'q' }
      it do
        expect { subject }.to_not change Anime, :count
        expect(entry).to be_persisted
      end

      describe 'blank special field' do
        let!(:anime) do
          create :anime, id: data[:id], japanese: 'q', desynced: %w(name)
        end
        before { data[:japanese] = nil }
        it { expect(entry.japanese).to eq 'q' }
      end

      describe 'desynced data field' do
        let!(:anime) do
          create :anime, id: data[:id], name: 'q', desynced: %w(name)
        end
        it { expect(entry.name).to eq 'q' }
      end

      describe 'desynced special field' do
        let!(:anime) do
          create :anime, id: data[:id], japanese: 'f', desynced: %w(japanese)
        end
        it { expect(entry.japanese).to eq 'f' }
      end
    end
  end
end
