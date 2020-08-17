describe BbCodes::Tags::SpoilerTag do
  subject { described_class.instance.format text }

  let(:text) { "#{prefix}[spoiler=#{label}]#{content}[/spoiler]#{suffix}" }
  let(:label) { 'blabla' }
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
  end

  describe 'block' do
    let(:prefix) { ["\n", '<div>', '</div>'].sample }

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
  end
  #
  # describe 'inline' do
  #   let(:text) { 'zxc [spoiler=spoiler]test[/spoiler] qwe' }
  #
  #   it do
  #     is_expected.to eq(
  #       <<~HTML.squish
  #         zxc <span class='b-spoiler_inline to-process'
  #           data-dynamic='spoiler_inline'><span>test</span></span> qwe
  #       HTML
  #     )
  #   end
  # end
  #
  # describe '[spoiler]' do
  #   let(:text) { "[spoiler]te\nst[/spoiler]" }
  #   it { is_expected.to_not include '[spoiler' }
  # end
  #
  # describe 'nested [spoiler]' do
  #   let(:text) { '[spoiler=test] [spoiler=1]test[/spoiler][/spoiler]' }
  #   it { is_expected.to_not include '[spoiler' }
  # end
end
