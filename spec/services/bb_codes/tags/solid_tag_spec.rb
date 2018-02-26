describe BbCodes::Tags::SolidTag do
  let(:tag) { BbCodes::Tags::SolidTag.instance }

  describe '#format' do
    subject { tag.format '[solid]test[/solid]' }
    it { is_expected.to eq '<div class="solid">test</div>' }
  end
end
