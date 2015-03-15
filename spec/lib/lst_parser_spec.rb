describe LstParser do
  let(:parser) { LstParser.new }
  let(:text) { "test1\ntest2\n---\ntest3\rtest4\r\n---\ntest5" }

  describe '#parse' do
    it { expect(parser.parse text).to eq [['test1', 'test2'], ['test3', 'test4'], ['test5']] }
  end
end
