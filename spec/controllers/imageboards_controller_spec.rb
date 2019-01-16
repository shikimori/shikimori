require 'webmock/rspec'

describe ImageboardsController do
  describe '#fetch' do
    let(:data) { { 'url' => url, 'test' => 'test' } }

    before { stub_request(:any, url).to_return body: data.to_json }
    subject! { get :fetch, params: { url: URI.encode(Base64.encode64(url).strip) } }

    context 'not allowed url' do
      let(:url) { 'http://lenta.ru/image.jpg' }
      it { expect(response).to be_forbidden }
    end

    context 'allowed url' do
      let(:url) { 'https://yande.re/post/index.json?page=1&limit=100&tags=kaichou_wa_maid-sama!' }
      it { expect(JSON.parse(response.body)).to eq data }
    end
  end

  describe '#autocomplete' do
    let!(:tag_1) { create :danbooru_tag, name: 'ffff' }
    let!(:tag_2) { create :danbooru_tag, name: 'testt' }
    let!(:tag_3) { create :danbooru_tag, name: 'zula zula' }

    subject! { get :autocomplete, params: { search: 'test' } }

    it do
      expect(collection).to have(1).item
      expect(response).to have_http_status :success
    end
  end
end
