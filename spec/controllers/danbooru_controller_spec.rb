require 'webmock/rspec'

describe DanbooruController do
  describe '#yandere' do
    let(:url) { 'https://yande.re/post/index.json?page=1&limit=100&tags=kaichou_wa_maid-sama!' }
    let(:data) { { 'url' => url, 'test' => 'test' } }
    before { stub_request(:any, url).to_return body: data.to_json }

    it 'should raise forbidden for not allowed urls' do
      get :yandere, url: Base64.encode64('http://lenta.ru/image.jpg').strip
      expect(response).to be_forbidden
    end

    it 'should render json' do
      get :yandere, url: URI.encode(Base64.encode64(url).strip)
      expect(JSON.parse(response.body)).to eq data
    end
  end
end
