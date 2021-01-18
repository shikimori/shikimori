describe VideoExtractor::VimeoExtractor, :vcr do
  let(:service) { described_class.new url }
  subject { service.fetch }

  let(:url) { 'http://vimeo.com/426453510' }

  its(:hosting) { is_expected.to eq :vimeo }
  its(:image_url) { is_expected.to eq 'https://i.vimeocdn.com/video/904713405_640x360.jpg?r=pad' }
  its(:player_url) { is_expected.to eq '//player.vimeo.com/video/426453510' }
end
