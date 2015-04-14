describe BbCodes::ListTag do
  let(:tag) { BbCodes::ListTag.instance }

  describe '#format' do
    context 'with [list]' do
      subject { tag.format '[list][*]первая строка[*]вторая строка[/list]' }
      it { should eq '<ul class="b-list"><li>первая строка</li><li>вторая строка</li></ul>' }
    end

    context '[*] only' do
      subject { tag.format '[*]первая строка[*]вторая строка' }
      it { should eq '<ul class="b-list"><li>первая строка</li></ul><ul class="b-list"><li>вторая строка</li></ul>' }
    end

    context '[*] with brs' do
      subject { tag.format '[*]первая строка<br>test<br><br>test2' }
      it { should eq '<ul class="b-list"><li>первая строка<br>test</li></ul><br>test2' }
    end
  end
end
