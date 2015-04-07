describe BbCodes::PTag do
  let(:tag) { BbCodes::PTag.instance }

  describe '#format' do
    subject { tag.format '[p]test[/p]' }
    it { should eq '<div class="prgrph">test</div>' }
  end
end
