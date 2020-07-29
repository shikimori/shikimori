describe BbCodes::Tags::ListTag do
  subject { described_class.instance.format text }

  context 'with [list]' do
    let(:text) { '[list][*]первая строка[*]вторая строка[/list]' }
    it { is_expected.to eq '<ul class="b-list"><li>первая строка</li><li>вторая строка</li></ul>' }
  end

  context '[list] br after' do
    let(:text) { "[list][*]первая строка[/list]\n" }
    it { is_expected.to eq '<ul class="b-list"><li>первая строка</li></ul>' }
  end

  context '[*] only' do
    let(:text) { '[*]первая строка[*]вторая строка' }
    it { is_expected.to eq '<ul class="b-list"><li>первая строка</li></ul><ul class="b-list"><li>вторая строка</li></ul>' }
  end

  context '[*] with brs' do
    let(:text) { "[*]первая строка\ntest\n\ntest2" }
    it { is_expected.to eq "<ul class=\"b-list\"><li>первая строка\ntest</li></ul>\ntest2" }
  end
end
