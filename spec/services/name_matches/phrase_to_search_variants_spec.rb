describe NameMatches::PhraseToSearchVariants do
  let(:service) { NameMatches::PhraseToSearchVariants.new terms }
  subject! { service.call }

  describe '#call' do
    let(:terms) { 'Test1 x Test2: kaikaikai' }
    it do
      is_expected.to eq [
        ['test1xtest2kaikaikai'],
        ['test1xtest2kaikaikai', 'test1xtest2', 'kaikaikai']
      ]
    end
  end
end
