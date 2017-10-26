describe BbCodes::Tags::RightTag do
  let(:tag) { BbCodes::Tags::RightTag.instance }

  describe '#format' do
    subject { tag.format '[right]test[/right]' }
    it { should eq '<div class="right-text">test</div>' }
  end
end
