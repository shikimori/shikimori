describe BbCodes::WallImageTag do
  let(:tag) { BbCodes::WallImageTag.instance }

  describe '#format' do
    subject { tag.format text }

    let(:text) { "[wall_image=#{user_image.id}]" }
    let(:user_image) { create :user_image, user: build_stubbed(:user) }

    it do
      is_expected.to eq "<a href=\"#{user_image.image.url :original, false}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\"/>\
</a>"
    end
  end
end
