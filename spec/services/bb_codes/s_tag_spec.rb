describe BbCodes::STag do
  let(:tag) { BbCodes::STag.instance }

  describe '#format' do
    subject { tag.format '[s]test[/s]' }
    it { should eq '<del>test</del>' }
  end
end
