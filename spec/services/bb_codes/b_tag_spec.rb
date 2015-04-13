describe BbCodes::BTag do
  let(:tag) { BbCodes::BTag.instance }

  describe '#format' do
    subject { tag.format '[b]test[/b]' }
    it { should eq '<strong>test</strong>' }
  end
end
