describe NameMatches::Phraser do
  let(:phraser) { NameMatches::Phraser.new }

  def fix phrase
    phraser.fix phrase
  end

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
  end
end
