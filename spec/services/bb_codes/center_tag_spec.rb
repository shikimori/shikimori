describe BbCodes::CenterTag do
  let(:tag) { BbCodes::CenterTag.instance }

  describe '#format' do
    subject { tag.format '[center]test[/center]' }
    it { should eq '<center>test</center>' }
  end
end
