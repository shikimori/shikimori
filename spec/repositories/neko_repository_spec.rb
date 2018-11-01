describe NekoRepository do
  let(:service) { NekoRepository.instance }

  describe 'enumerable' do
    it do
      expect(service.first).to be_kind_of Neko::Rule
      expect(service).to have_at_least(10).items
    end
  end

  describe '#find' do
    subject { service.find neko_id, level }
    let(:level) { ['1', 1].sample }

    context 'matched neko_id' do
      let(:neko_id) { [:animelist, 'animelist'].sample }

      it { is_expected.to be_kind_of Neko::Rule }
      it { is_expected.to_not eq Neko::Rule::NO_RULE }
    end

    context 'not matched neko_id' do
      let(:neko_id) { %i[test zxc].sample }

      it { is_expected.to be_kind_of Neko::Rule }
      it { is_expected.to eq Neko::Rule::NO_RULE }
    end

    context 'no neko_id' do
      let(:neko_id) { ['', nil].sample }
      it { is_expected.to be_nil }
    end
  end
end
