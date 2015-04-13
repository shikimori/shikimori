describe BbCodes::SizeTag do
  let(:tag) { BbCodes::SizeTag.instance }

  describe '#format' do
    subject { tag.format '[size=13]test[/size]' }
    it { should eq '<span style="font-size: 13px;">test</span>' }
  end
end
