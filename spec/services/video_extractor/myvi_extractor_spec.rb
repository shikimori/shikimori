describe VideoExtractor::MyviExtractor, :vcr do
  let(:service) { described_class.instance }

  describe 'fetch' do
    subject { service.fetch url }
    let(:url) do
      [
        'https://www.myvi.top/idaofy?v=kcptso3b1mpr8n8fc3xyof5tyh',
        'https://myvi.top/idaofy?v=kcptso3b1mpr8n8fc3xyof5tyh',
        'http://www.myvi.top/idaofy?v=kcptso3b1mpr8n8fc3xyof5tyh',
        'http://myvi.top/idaofy?v=kcptso3b1mpr8n8fc3xyof5tyh'
      ].sample
    end

    its(:hosting) { is_expected.to eq :myvi }
    its(:image_url) { is_expected.to eq UrlGenerator.instance.camo_url('//www.myvi.top/stream/preview/UxsbQyGS2kOI5WZeCBdxBw2/tm1.jpg') }
    its(:player_url) { is_expected.to eq '//www.myvi.top/embed/kcptso3b1mpr8n8fc3xyof5tyh' }
  end
end
