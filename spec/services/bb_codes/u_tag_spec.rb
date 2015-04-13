describe BbCodes::UTag do
  let(:tag) { BbCodes::UTag.instance }

  describe '#format' do
    subject { tag.format '[u]test[/u]' }
    it { should eq '<span style="text-decoration: underline;">test</span>' }
  end
end
