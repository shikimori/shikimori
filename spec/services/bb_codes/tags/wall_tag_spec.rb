describe BbCodes::Tags::WallTag do
  let(:tag) { BbCodes::Tags::WallTag.instance }

  describe '#format' do
    subject { tag.format '[wall]test[/wall]' }
    it do
      is_expected.to eq(
        '<div class="b-shiki_wall to-process" data-dynamic="wall"><div class="inner">test</div></div>'
      )
    end
  end
end
