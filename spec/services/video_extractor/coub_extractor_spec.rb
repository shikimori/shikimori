describe VideoExtractor::CoubExtractor, :vcr do
  let(:service) { described_class.instance }

  describe 'fetch' do
    subject { service.fetch url }
    let(:url) { 'http://coub.com/view/bqn2pda' }

    its(:hosting) { is_expected.to eq :coub }
    its(:image_url) do
      is_expected.to eq(
        'https://coubsecure-s.akamaihd.net/get/b57/p/coub/simple/cw_image/c4dfc4d2557/91e190f2fa14b59a63d21/med_1439318693_00032.jpg'
      )
    end
    its(:player_url) do
      is_expected.to eq(
        'https://coub.com/embed/bqn2pda?autostart=true&startWithHD=true'
      )
    end
  end
end
