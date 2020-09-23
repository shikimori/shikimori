describe BbCodes::Markdown::HeadlineParser do
  subject { described_class.instance.format text }

  context 'h2' do
    let(:text) { '# test' }
    it { is_expected.to eq '<h2>test</h2>' }

    context 'sample' do
      let(:text) { "# test\nzxc" }
      it { is_expected.to eq '<h2>test</h2>zxc' }
    end

    context 'sample' do
      let(:text) { "# test\n# zxc" }
      it { is_expected.to eq '<h2>test</h2><h2>zxc</h2>' }
    end

    context 'sample' do
      let(:text) { ' # test' }
      it { is_expected.to eq text }
    end

    context 'inside [div]' do
      let(:text) { "[div]\n# test\n[/div]" }
      it { is_expected.to eq "[div]\n<h2>test</h2>[/div]" }
    end

    context 'inside <div>' do
      let(:text) { "<div>\n# test\n</div>" }
      it { is_expected.to eq "<div>\n<h2>test</h2></div>" }
    end

    context 'moves through inner tags' do
      let(:text) { "# #{content}" }
      let(:content) do
        [
          "z [spoiler=x]x\nx[/spoiler]",
          "z [spoiler_v1]x\nx[/spoiler_v1]"
        ].sample
      end

      it { is_expected.to eq "<h2>#{content}</h2>" }

      context 'not closed bbcode' do
        let(:content) { "z [spoiler=x]x\nx[/div]" }
        it { is_expected.to eq '<h2>z [spoiler=x]x</h2>x[/div]' }
      end
    end
  end

  context 'h3' do
    let(:text) { '## test' }
    it { is_expected.to eq '<h3>test</h3>' }
  end

  context 'h4' do
    let(:text) { '### test' }
    it { is_expected.to eq '<h4>test</h4>' }
  end

  context 'headline' do
    let(:text) { '#### test' }
    it { is_expected.to eq "<div class='headline'>test</div>" }
  end

  context 'midheadline' do
    let(:text) { '##### test' }
    it { is_expected.to eq "<div class='midheadline'>test</div>" }
  end
end
