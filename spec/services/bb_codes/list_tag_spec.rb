describe BbCodes::ListTag do
  let(:tag) { BbCodes::ListTag.instance }

  describe '#format' do
    subject { tag.format '[list][*]первая строка[*]вторая строка[/list]' }
    it { should eq '<ul><li>первая строка</li><li>вторая строка</li></ul>' }
  end
end
