describe BbCodes::Tags::PosterTag do
  subject { described_class.instance.format text }

  context 'deleted image' do
    let(:text) { "[poster=#{described_class::DELETED_MARKER}]" }
    it do
      is_expected.to eq(
        "<img src='#{BbCodes::Tags::ImageTag::DELETED_IMAGE_PATH}' loading='lazy' />"
      )
    end
  end

  context 'external image' do
    let(:url) { 'http://site.com/site-url' }
    let(:camo_url) { UrlGenerator.instance.camo_url url }
    let(:text) { "[poster]#{url}[/poster]" }

    it do
      is_expected.to eq(
        "<span class='b-image b-poster no-zoom'>" \
          "<img src='#{camo_url}' loading='lazy' />" \
        '</span>'
      )
    end
  end

  context 'shiki image' do
    let(:text) { "[poster=#{user_image.id}]" }
    let(:user_image) do
      create :user_image, user: build_stubbed(:user), width: 400, height: 500
    end
    let(:attrs) { { id: user_image.id, isPoster: true } }

    it do
      is_expected.to eq(
        "<span class='b-image b-poster no-zoom' data-attrs='#{attrs.to_json}'>" \
          "<img src='#{user_image.image.url :original, false}' " \
            "data-width='#{user_image.width}' " \
            "data-height='#{user_image.height}' " \
            "loading='lazy' />"\
        '</span>'
      )
    end
  end
end
