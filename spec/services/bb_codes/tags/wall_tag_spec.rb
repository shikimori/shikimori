describe BbCodes::Tags::WallTag do
  subject { described_class.instance.format text }
  let(:text) { '[wall]test[/wall]' }
  it { is_expected.to eq '<div class="b-shiki_wall to-process" data-dynamic="wall">test</div>' }
end
