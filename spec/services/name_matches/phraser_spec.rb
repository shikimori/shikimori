describe NameMatches::Phraser do
  let(:phraser) { NameMatches::Phraser.new }

  describe '#fix' do
    it { expect(phraser.fix nil).to eq '' }
    it { expect(phraser.fix '[test] ☆ † ♪ - : (TEST)').to eq 'testtest' }
    it { expect(phraser.fix ['[test]', 'test' '☆ †♪', '(TEST2)']).to eq ['test', 'test2'] }
  end

  describe '#multiply_phrases' do
    it { expect(phraser.multiply_phrases ['zzz 2nd season'], /2nd season/, 's2')
      .to eq ['zzz 2nd season', 'zzz s2'] }
    it { expect(phraser.multiply_phrases ['mahou shoujo madoka magica'], 'magica', 'magika')
      .to eq ['mahou shoujo madoka magica', 'mahou shoujo madoka magika'] }
  end

  describe '#replace_phrases' do
    let(:phrases) { ['test', 'teest', 'test2'] }
    it { expect(phraser.replace_phrases phrases, /te+/, 'te').to eq ['test', 'test2'] }
  end

  describe '#phrase_variants' do
    it { expect(phraser.phrase_variants 'madouka magica')
      .to eq ['madoka magika'] }

    it { expect(phraser.phrase_variants 'zz [ТВ]').to eq ['zz'] }
    it { expect(phraser.phrase_variants 'zz [ТВ-4]').to eq ['zz s4'] }
    it { expect(phraser.phrase_variants 'zz 2nd season').to eq ['zz s2'] }
    it { expect(phraser.phrase_variants 'season 6').to eq ['s6'] }
    it { expect(phraser.phrase_variants 'JoJo no Kimyou na Bouken (2000)').to eq ['jojo no kimyo na boken'] }

    describe 'user bracket_alternatives' do
      let(:phrase) { 'Kigeki [Sweat Punch Series 3]' }
      let(:result) { ['kigeki sweat punch s3', 'kigeki', 'sweat punch s3'] }
      it { expect(phraser.phrase_variants phrase).to eq result }
    end
  end

  describe '#variants' do
    it { expect(phraser.variants 'madouka').to eq ['madoka'] }
  end

  describe '#split_by_delimiters' do
    # it { expect(phraser.split_by_delimiters '').to eq [] }
  end

  describe '#bracket_alternatives' do
    it { expect(phraser.bracket_alternatives 'Kigeki [Sweat Punch Series 3]')
      .to eq ['kigeki', 'sweat punch series 3'] }
  end

  describe '#words_combinations' do
    let(:lain) { 'lain - serial experiments' }
    it { expect(phraser.words_combinations [lain]).to eq ['serial experiments lain'] }
    it { expect(phraser.words_combinations ['zz [ТВ-4]']).to be_empty }
  end
end
