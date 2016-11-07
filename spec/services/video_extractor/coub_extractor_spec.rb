describe VideoExtractor::CoubExtractor, :vcr do
  let(:service) { VideoExtractor::CoubExtractor.new url }

  describe 'fetch' do
    subject { service.fetch }
    let(:url) { 'http://coub.com/view/bqn2pda' }

    its(:hosting) { is_expected.to eq :coub }
    its(:image_url) { is_expected.to eq '//coubsecure-s.akamaihd.net/get/b57/p/coub/simple/cw_image/c4dfc4d2557/91e190f2fa14b59a63d21/med_1439318693_00032.jpg' }
    its(:player_url) { is_expected.to eq '//c-cdn.coub.com/fb-player.swf?bot_type=unknown&coubID=bqn2pda' }
  end
end
