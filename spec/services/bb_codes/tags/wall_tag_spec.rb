describe BbCodes::Tags::WallTag do
  subject { described_class.instance.format text }
  let(:text) { '[wall]test[/wall]' }
  it do
    is_expected.to eq(
      "<div class='b-shiki_wall to-process' data-dynamic='wall'>test</div>"
    )
  end

  describe 'images count restriction' do
    let(:text) { "[wall]#{content}[/wall]" }
    let(:content) do
      [
        '[image=fsd',
        '[wall_image=fsd',
        '[poster=fsd',
        '[/img]'
      ].sample * count
    end

    context 'allowed' do
      let(:count) { described_class::MAXIMUM_IMAGES }
      it do
        is_expected.to eq(
          "<div class='b-shiki_wall to-process' data-dynamic='wall'>#{content}</div>"
        )
      end
    end

    context 'not allowed', :focus do
      let(:count) { described_class::MAXIMUM_IMAGES + 1 }
      it { is_expected.to eq text }
    end
  end
end
