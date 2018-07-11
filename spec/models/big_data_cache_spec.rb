describe BigDataCache do
  describe 'validations' do
    it { is_expected.to validate_presence_of :key }
    it { is_expected.to validate_presence_of :value }
  end

  describe 'class methods' do
    describe '.write' do
      include_context :timecop

      subject { described_class.write key, value, expires_in: expires_at }

      let(:key) { 'key' }
      let(:value) { { a: :b } }
      let(:expires_at) { 1.hour }

      context 'no key' do
        let(:entry) { BigDataCache.find_by key: key }

        it do
          expect { subject }.to change(BigDataCache, :count).by 1
          expect(entry.value).to eq value
          expect(entry.expires_at).to be_within(0.1).of expires_at.from_now
        end

        context 'no expires_at' do
          let(:expires_at) { nil }

          it do
            expect { subject }.to change(BigDataCache, :count).by 1
            expect(entry.value).to eq value
            expect(entry.expires_at).to be_nil
          end
        end
      end

      context 'has key' do
        let!(:entry) { create :big_data_cache, key: key }

        it do
          expect { subject }.to_not change BigDataCache, :count
          expect(entry.reload.value).to eq value
          expect(entry.expires_at).to be_within(0.1).of expires_at.from_now
        end
      end
    end

    describe '.read' do
      subject { described_class.read key }
      let(:key) { 'test' }

      context 'has key' do
        context 'not expred' do
          let!(:entry) { create :big_data_cache, key: key, expires_at: 1.minute.from_now }
          it { is_expected.to eq entry.value }
        end

        context 'expired' do
          let!(:entry) { create :big_data_cache, key: key, expires_at: 1.minute.ago }
          it { is_expected.to be_nil }
        end
      end

      context 'no key' do
        it { is_expected.to be_nil }
      end
    end
  end
end
