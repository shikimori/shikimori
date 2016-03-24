describe BbCodes::PosterTag do
  let(:tag) { BbCodes::PosterTag.instance }

  describe '#format' do
    subject { tag.format text }

    context 'external image' do
      let(:url) { 'http://site.com/site-url' }
      let(:text) { "[poster]#{url}[/poster]" }
      it { is_expected.to eq "<img class=\"b-poster\" src=\"#{url.without_protocol}\" />" }
    end

    context 'shiki image' do
      let(:text) { "[poster=#{user_image.id}]" }
      let(:user_image) { create :user_image, user: build_stubbed(:user), width: 400, height: 500 }

      it { is_expected.to eq(
        "<img class=\"b-poster\" \
src=\"#{user_image.image.url :original, false}\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />") }
    end
  end
end
