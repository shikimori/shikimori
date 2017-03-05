describe Import::BannedIds do
  let(:service) { Import::BannedIds.instance }

  describe '#banned?' do
    subject { service.banned? id, type }
    let(:id) { 99_999_999 }
    let(:type) { :anime }

    it { is_expected.to eq true }

    context 'wrong type' do
      let(:type) { :character }
      it { is_expected.to eq false }
    end

    context 'wrong id' do
      let(:id) { 9_999_999 }
      it { is_expected.to eq false }
    end
  end
end
