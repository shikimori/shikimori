describe VideoExtractor::VimeoExtractor, :vcr do
  let(:service) { described_class.instance }
  subject { service.fetch url }

  let(:url) { 'http://vimeo.com/426453510' }

  it do
    is_expected.to have_attributes(
      hosting: :vimeo,
      image_url: 'https://i.vimeocdn.com/video/904713405_640x360.jpg?r=pad',
      player_url: '//player.vimeo.com/video/426453510'
    )
  end
end
