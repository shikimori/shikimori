describe BigDataCache do
  describe 'validations' do
    it { is_expected.to validate_presence_of :key }
    it { is_expected.to validate_presence_of :value }
  end

  describe 'class methods' do
    describe '.read' do
      subject { described_class.read :test }

      context 'has key' do
        context 'not expred' do
          let!(:entry) { create :big_data_cache, key: 'test', expires_at: 1.minute.from_now }
          it { is_expected.to eq entry.value }
        end

        context 'expired' do
          let!(:entry) { create :big_data_cache, key: 'test', expires_at: 1.minute.ago }
          it { is_expected.to be_nil }
        end
      end

      context 'no key' do
        it { is_expected.to be_nil }
      end
    end
  end
end
