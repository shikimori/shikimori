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

  describe '#phrase_variants' do
    it { expect(phraser.phrase_variants 'madoka magica')
      .to eq ['madoka magica', 'madoka magika', 'madouka magica', 'madouka magika'] }
    it { expect(phraser.phrase_variants 'zz [ТВ]').to include 'zz' }
    it { expect(phraser.phrase_variants 'zz [ТВ-4]').to include 'zz тв4' }
    it { expect(phraser.phrase_variants 'zz [ТВ-4]').to include 'zz tv4' }
    it { expect(phraser.phrase_variants 'zz 2nd season').to include 'zz tv2' }
    it { expect(phraser.phrase_variants 'season 10').to include 's10' }
    it { expect(phraser.phrase_variants 'JoJo no Kimyou na Bouken (2000)').to include 'jojo no kimyou na bouken' }

    describe 'user bracket_alternatives' do
      let(:phrase) { 'Kigeki [Sweat Punch Series 3]' }
      it do
        expect(phraser.phrase_variants phrase).to include 'kigeki'
        expect(phraser.phrase_variants phrase).to include 'sweat punch series 3'
        expect(phraser.phrase_variants phrase).to include 'sweat punch'
      end
    end
  end

  describe '#variants' do
    it { expect(phraser.variants 'madoka').to eq ['madoka', 'madouka'] }
  end

  describe '#split_by_delimiters' do
    # it { expect(phraser.split_by_delimiters '').to eq [] }
  end

  describe '#bracket_alternatives' do
    it { expect(phraser.bracket_alternatives 'Kigeki [Sweat Punch Series 3]')
      .to eq ['kigeki', 'sweat punch series 3'] }
  end

  describe '#words_combinations' do
    it { expect(phraser.words_combinations ['lain - serial experiments'])
      .to eq ['serial experiments lain'] }
  end
end
