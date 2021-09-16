describe BbCodes::Tags::PosterTag do
  subject { described_class.instance.format text }

  context 'deleted image' do
    let(:text) { "[poster=#{described_class::DELETED_MARKER}]" }
    it { is_expected.to eq BbCodes::Tags::ImageTag::DELETED_IMAGE_HTML }
  end

  context 'external image' do
    let(:image_url) { 'http://site.com/site-url?a=1&b=2' }
    let(:escaped_image_url) { ERB::Util.h image_url }
    let(:camo_url) { UrlGenerator.instance.camo_url image_url }
    let(:text) { "[poster]#{escaped_image_url}[/poster]" }
    let(:attrs) { { src: image_url } }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <span class='b-image b-poster no-zoom'
            data-attrs='#{ERB::Util.h attrs.to_json}'><img src='#{ERB::Util.h camo_url}'
            loading='lazy' /></span>
        HTML
      )
    end
  end

  context 'shiki image' do
    let(:text) { "[poster=#{user_image.id}]" }
    let(:user_image) do
      create :user_image, user: build_stubbed(:user), width: 400, height: 500
    end
    let(:attrs) { { id: user_image.id } }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <span class='b-image b-poster no-zoom'
            data-attrs='#{ERB::Util.h attrs.to_json}'><img
              src='#{user_image.image.url :original, false}'
              data-width='#{user_image.width}'
              data-height='#{user_image.height}'
              loading='lazy' /></span>
        HTML
      )
    end
  end
end
