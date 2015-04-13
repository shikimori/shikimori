describe BbCodes::RightTag do
  let(:tag) { BbCodes::RightTag.instance }

  describe '#format' do
    subject { tag.format '[right]test[/right]' }
    it { should eq '<div class="right-text">test</div>' }
  end
end
