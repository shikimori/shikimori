describe Import::Base do
  class Import::Test < Import::Base
    def klass
      Anime
    end
  end
  let(:service) { Import::Test.new data }
  let(:data) { { id: 9_876_543, name: 'Zzzz' } }

  before { Timecop.freeze }
  after { Timecop.return }

  subject(:entry) { service.call }

  describe '#call' do
    it { expect { subject }.to change(Anime, :count).by 1 }

    it do
      expect(entry).to be_persisted
      expect(entry).to be_valid
      expect(entry.imported_at).to eq Time.zone.now
      expect(entry).to have_attributes data
    end
  end
end
