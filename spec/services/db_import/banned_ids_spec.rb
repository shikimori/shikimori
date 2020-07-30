describe DbImport::BannedIds do
  let(:service) { described_class.instance }

  describe '#banned?' do
    subject { service.banned? id, type }
    let(:id) { 111111111 }
    let(:type) { :anime }

    it { is_expected.to eq true }

    context 'wrong type' do
      let(:type) { :character }
      it { is_expected.to eq false }
    end

    context 'wrong id' do
      let(:id) { 11111111 }
      it { is_expected.to eq false }
    end
  end
end
