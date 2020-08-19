describe BbCodes::Tags::SpoilerTag do
  subject { described_class.instance.format text }

  let(:text) do
    eqls_label = label.present? ? "=#{label}" : ''
    "#{prefix}[#{tag}#{eqls_label}]#{content}[/#{tag}]#{suffix}"
  end
  let(:tag) { 'spoiler' }
  let(:label) { 'bl<b>a</b>bla' }
  let(:prefix) { '' }
  let(:suffix) { ['\n', ' ', 'zxc'].sample }
  let(:content) { 'test' }

  describe 'old style' do
    let(:prefix) { 'qwe ' }
    let(:content) { ['test', "te\nst"].sample }

    it do
      is_expected.to eq(
        prefix +
          "<div class='b-spoiler unprocessed'>" \
            "<label>#{label}</label>" \
            "<div class='content'>" \
              "<div class='before'></div>" \
              "<div class='inner'>#{content}</div>" \
              "<div class='after'></div>" \
            '</div>' \
          '</div>' + suffix
      )
    end

    context 'spoiler_v1' do
      let(:prefix) { ["\n", '<div>', '</div>'].sample }
      let(:tag) { 'spoiler_v1' }

      it do
        is_expected.to eq(
          prefix +
            "<div class='b-spoiler unprocessed'>" \
              "<label>#{label}</label>" \
              "<div class='content'>" \
                "<div class='before'></div>" \
                "<div class='inner'>#{content}</div>" \
                "<div class='after'></div>" \
              '</div>' \
            '</div>' + suffix
        )
      end
    end
  end

  describe 'block' do
    let(:prefix) { ["\n", '<div>', '</div>'].sample }
    let(:label) { 'blabla' }

    context 'no \n suffix' do
      let(:suffix) { [' ', 'zxc'].sample }

      it do
        is_expected.to eq(
          prefix +
            "<div class='b-spoiler_block to-process' data-dynamic='spoiler_block'>" \
              "<button>#{label}</button>" \
              "<div>#{content}</div>" \
            '</div>' + suffix
        )
      end
    end

    context '\n inside' do
      let(:content) { "qwerty\n" }
      it do
        is_expected.to eq(
          prefix +
            "<div class='b-spoiler_block to-process' data-dynamic='spoiler_block'>" \
              "<button>#{label}</button>" \
              '<div>qwerty</div>' \
            '</div>' + suffix
        )
      end
    end

    context '\n suffix' do
      let(:suffix) { "\n" }

      it do
        is_expected.to eq(
          prefix +
            "<div class='b-spoiler_block to-process' data-dynamic='spoiler_block'>" \
              "<button>#{label}</button>" \
              "<div>#{content}</div>" \
            '</div>'
        )
      end
    end

    context 'label with markup' do
      let(:label) { 'bl<b>a</b>bla' }
      it { is_expected.to_not include 'b-spoiler_block' }

      context 'tag is spoiler_block' do
        let(:tag) { 'spoiler_block' }
        it { is_expected.to include 'b-spoiler_block' }
      end
    end
  end

  describe 'inline' do
    let(:label) { described_class::INLINE_LABELS.sample }
    let(:prefix) { 'qwe ' }

    it do
      is_expected.to eq(
        prefix +
          "<span class='b-spoiler_inline to-process' data-dynamic='spoiler_inline'>" \
            "<span>#{content}</span>" \
          '</span>' + suffix
      )
    end
  end

  describe '[spoiler]' do
    let(:text) { "[spoiler]te\nst[/spoiler]" }
    it { is_expected.to_not include '[spoiler' }
  end

  describe 'nested [spoiler]' do
    let(:text) { '[spoiler=test] [spoiler=1]test[/spoiler][/spoiler]' }
    it { is_expected.to_not include '[spoiler' }
  end
end
