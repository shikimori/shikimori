describe VideoExtractor::VimeoExtractor, :vcr do
  let(:service) { VideoExtractor::VimeoExtractor.new url }

  context 'fetch' do
    subject { service.fetch }
    context do
      let(:url) { 'http://vimeo.com/85212054' }

      its(:hosting) { is_expected.to eq :vimeo }
      its(:image_url) { is_expected.to eq '//i.vimeocdn.com/video/463402969_1280x720.jpg' }
      its(:player_url) { is_expected.to eq '//player.vimeo.com/video/85212054' }
    end

    context do
      let(:url) { 'https://vimeo.com/231864130' }

      its(:hosting) { is_expected.to eq :vimeo }
      its(:image_url) { is_expected.to eq '//i.vimeocdn.com/filter/overlay?src0=https%3A%2F%2Fi.vimeocdn.com%2Fvideo%2F652783239_1280x716.jpg&src1=https%3A%2F%2Ff.vimeocdn.com%2Fimages_v6%2Fshare%2Fplay_icon_overlay.png' }
      its(:player_url) { is_expected.to eq '//player.vimeo.com/video/231864130' }
    end
  end
end
