describe Misc::SanitizeEvilCss do
  subject { described_class.call css }

  context 'evil css' do
    context 'sample' do
      let(:css) { 'a { color: &#1234; }' }
      it { is_expected.to eq 'a { color: 1234; }' }
    end

    context 'sample' do
      let(:css) { '@import url(evil.css);' }
      it { is_expected.to eq '' }
    end

    context 'sample' do
      let(:css) { '@im@importport url(http://evil.css)' }
      it { is_expected.to eq 'url(http://evil.css)' }
    end

    context 'sample' do
      let(:css) { '@im/**/port url(http://evil.css);' }
      it { is_expected.to eq '' }
    end

    context 'sample' do
      let(:css) { '@@@import url();import url();import url(http://evil.css);' }
      it { is_expected.to eq '' }
    end

    context 'sample' do
      let(:css) { '\zxc' }
      it { is_expected.to eq 'xc' }
    end

    context 'sample' do
      let(:css) { "url('data:image/svg+xml,%3C%3Fxml asdasdasdasddd')" }
      it { is_expected.to eq "url('image/svg+xml,%3C%3Fxml asdasdasdasddd')" }
    end

    context 'sample' do
      let(:css) { "url('data:bla/bla')" }
      it { is_expected.to eq "url('bla/bla')" }
    end

    context 'sample' do
      let(:css) { "url('data:javascript')" }
      it { is_expected.to eq "url('data:')" }
    end

    context 'sample' do
      let(:css) { 'data:' }
      it { is_expected.to eq '' }
    end

    context 'sample' do
      let(:css) do
        [
          '\\@import',
          '@\\import',
          '@i\\mport',
          '@impor\\t'
        ].sample
      end
      it { is_expected.to eq '' }
    end
  end

  # this way it is used in some old styles
  context 'fix content' do
    context 'sample' do
      let(:css) { "content: '\\\\_f0e0';" }
      it { is_expected.to eq "content: '\\f0e0';" }
    end

    context 'sample' do
      let(:css) { "content: '\\\\f0e0';" }
      it { is_expected.to eq "content: '\\f0e0';" }
    end

    context 'sample' do
      let(:css) { "content: '\\\\_f0e0';" }
      it { is_expected.to eq "content: '\\f0e0';" }
    end

    context 'sample' do
      let(:css) { "content: '\\f0e0';" }
      it { is_expected.to eq "content: '\\f0e0';" }
    end
  end

  [
    "url('data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj')",
    "url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUC')",
    'url("data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAA")',
    'url("data:image/jpg;base64,/9j/4AAQSkZJRgABAQAAA")'
  ].each do |sample|
    context sample do
      let(:css) { sample }
      it { is_expected.to eq css }
    end
  end

  context 'sample' do
    let(:css) { 'a { background: red }' }
    it { is_expected.to eq css }
  end

  context 'sample' do
    let(:css) { '.description { background: red }' }
    it { is_expected.to eq css }
  end

  context 'sample' do
    let(:css) { ".b-rate .stars.background::before{content:'\\e83a\\e83a\\e83a\\e83a\\e83a'}" }
    it { is_expected.to eq css }
  end
end
