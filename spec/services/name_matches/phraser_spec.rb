describe NameMatches::Phraser do
  let(:service) { described_class.instance }

  describe '#variate' do
    it { expect(service.variate 'madouka magica').to eq ['madokamagika'] }
    it { expect(service.variate 'zz [ТВ-4]').to eq ['zzs4'] }
    it { expect(service.variate 'zz season 3').to eq ['zzs3'] }

    it { expect(service.variate 'Naruto: Shippuuden').to eq ['narutosippuden', 'sippuden'] }
    it { expect(service.variate 'Naruto Shippuden').to eq ['narutosippuden'] }

    context 'without splits' do
      let(:options) { { do_splits: false } }

      it { expect(service.variate 'zz [ТВ]', **options).to eq ['zztv'] }
      it { expect(service.variate 'zz (2000)', **options).to eq ['zz2000'] }
      it { expect(service.variate 'zz!', **options).to eq ['zz!'] }
      it { expect(service.variate 'zz, with comma', **options).to eq ['zzwithcomma'] }
    end

    context 'with splits' do
      let(:options) { { do_splits: true } }

      it { expect(service.variate 'zz [ТВ]', **options).to eq ['zztv', 'zz'] }
      it { expect(service.variate 'zz (2000)', **options).to eq ['zz2000', 'zz'] }
      it { expect(service.variate 'zz!', **options).to eq ['zz!', 'zz'] }
      it { expect(service.variate 'zz, with comma', **options).to eq ['zzwithcomma', 'withcomma'] }
    end

    describe 'user bracket_alternatives' do
      let(:phrase) { 'Kigeki [Sweat Punch Series 3]' }
      let(:result) { ['kigekisweatpunchs3', 'kigeki', 'sweatpunchs3'] }
      it { expect(service.variate phrase).to eq result }
    end
  end

  # describe '#variants' do
    # it { expect(service.variants 'madouka').to eq ['madoka'] }
  # end

  # describe '#split_by_delimiters' do
    # it { expect(service.split_by_delimiters '').to eq [] }
  # end

  describe '#bracket_alternatives' do
    it do
      expect(service.bracket_alternatives ['Kigeki [Sweat Punch Series 3]'])
      .to eq ['kigeki', 'sweat punch series 3']
    end
  end

  describe '#words_combinations' do
    let(:lain) { 'lain - serial experiments' }
    it { expect(service.words_combinations [lain]).to eq ['serial experiments lain'] }
    it { expect(service.words_combinations ['zz [ТВ-4]']).to be_empty }
  end

  describe '#replace_regexp' do
    let(:phrases) { ['test', 'teest', 'test2'] }
    it { expect(service.replace_regexp phrases, /te+/, 'te').to eq ['test', 'test2'] }
  end

  describe '#multiply' do
    it do
      expect(service.multiply ['zzz 2nd season'], /2nd season/, 's2')
      .to eq ['zzz 2nd season', 'zzz s2']
    end
    it do
      expect(service.multiply ['mahou shoujo madoka magica'], 'magica', 'magika')
      .to eq ['mahou shoujo madoka magica', 'mahou shoujo madoka magika']
    end
  end
end
