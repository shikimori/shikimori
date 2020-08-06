describe BbCodes::Tags::ListTag do
  subject { described_class.instance.format text }

  context 'bbcodes' do
    context '[list]' do
      context 'within [list]' do
        let(:text) { '[list][*]первая строка[*]вторая строка[/list]' }
        it do
          is_expected.to eq(
            "<ul class='b-list'><li>первая строка</li><li>вторая строка</li></ul>"
          )
        end
      end

      context '[list] br after' do
        let(:text) { "[list][*]первая строка[/list]\n" }
        it { is_expected.to eq "<ul class='b-list'><li>первая строка</li></ul>" }
      end
    end

    context '[*]' do
      context '[*] only' do
        let(:text) { '[*]первая строка[*]вторая строка' }
        it do
          is_expected.to eq(
            "<ul class='b-list'><li>первая строка</li></ul>" \
              "<ul class='b-list'><li>вторая строка</li></ul>"
          )
        end
      end

      context '[*] with brs' do
        let(:text) { "[*]первая строка\ntest\n\ntest2" }
        it { is_expected.to eq "<ul class='b-list'><li>первая строка\ntest</li></ul>\ntest2" }
      end
    end
  end

  context 'markdown' do
    context 'broken samples' do
      let(:text) { ['-a', ' -a', ' - a'].sample }
      it { is_expected.to eq text }
    end

    context 'single line' do
      let(:text) { ['- a', '+ a', '* a'].sample }
      it { is_expected.to eq "<ul class='b-list'><li>a</li></ul>" }
    end

    context 'item content on next line' do
      let(:text) { "- a\n  b" }
      it { is_expected.to eq "<ul class='b-list'><li>a\nb</li></ul>" }
    end

    context 'content after' do
      let(:text) { "- a\nb" }
      it { is_expected.to eq "<ul class='b-list'><li>a</li></ul>b" }
    end

    context 'multiline' do
      let(:text) { "- a\n- b" }
      it { is_expected.to eq "<ul class='b-list'><li>a</li><li>b</li></ul>" }
    end
  end
end
