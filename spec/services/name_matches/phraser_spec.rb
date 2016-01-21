describe NameMatches::Phraser do
  let(:service) { NameMatches::Phraser.instance }

  describe '#multiply' do
    it { expect(service.multiply ['zzz 2nd season'], /2nd season/, 's2')
      .to eq ['zzz 2nd season', 'zzz s2'] }
    it { expect(service.multiply ['mahou shoujo madoka magica'], 'magica', 'magika')
      .to eq ['mahou shoujo madoka magica', 'mahou shoujo madoka magika'] }
  end

  describe '#replace_regexp' do
    let(:phrases) { ['test', 'teest', 'test2'] }
    it { expect(service.replace_regexp phrases, /te+/, 'te').to eq ['test', 'test2'] }
  end

  describe '#phrase_variants' do
    it { expect(service.phrase_variants 'madouka magica')
      .to eq ['madoka magika'] }

    it { expect(service.phrase_variants 'zz [ТВ]').to eq ['zz'] }
    it { expect(service.phrase_variants 'zz [ТВ-4]').to eq ['zz s4'] }
    it { expect(service.phrase_variants 'JoJo no Kimyou na Bouken (2000)').to eq ['jojo no kimyo na boken'] }

    describe 'user bracket_alternatives' do
      let(:phrase) { 'Kigeki [Sweat Punch Series 3]' }
      let(:result) { ['kigeki sweat punch s3', 'kigeki', 'sweat punch s3'] }
      it { expect(service.phrase_variants phrase).to eq result }
    end
  end

  describe '#variants' do
    it { expect(service.variants 'madouka').to eq ['madoka'] }
  end

  describe '#split_by_delimiters' do
    # it { expect(service.split_by_delimiters '').to eq [] }
  end

  describe '#bracket_alternatives' do
    it { expect(service.bracket_alternatives 'Kigeki [Sweat Punch Series 3]')
      .to eq ['kigeki', 'sweat punch series 3'] }
  end

  describe '#words_combinations' do
    let(:lain) { 'lain - serial experiments' }
    it { expect(service.words_combinations [lain]).to eq ['serial experiments lain'] }
    it { expect(service.words_combinations ['zz [ТВ-4]']).to be_empty }
  end
end
