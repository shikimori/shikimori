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

    context 'inside div' do
      let(:text) { '[div]# test[/div]' }
      it { is_expected.to eq '<div><h2>test</h2></div>' }
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
