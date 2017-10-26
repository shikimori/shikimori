describe BbCodes::Tags::UTag do
  let(:tag) { BbCodes::Tags::UTag.instance }

  describe '#format' do
    subject { tag.format '[u]test[/u]' }
    it { should eq '<span style="text-decoration: underline;">test</span>' }
  end
end
