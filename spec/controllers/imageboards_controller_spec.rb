require 'webmock/rspec'

describe ImageboardsController do
  describe '#index' do
    let(:data) { [{ 'url' => url, 'test' => 'test' }] }

    before { stub_request(:any, url).to_return body: data.to_json }
    subject do
      get :index,
        params: {
          url: Addressable::URI.encode(Base64.encode64(url).strip)
        }
    end

    context 'not allowed url' do
      let(:url) { 'http://lenta.ru/image.jpg' }
      it { expect { subject }.to raise_error CanCan::AccessDenied }
    end

    context 'allowed url' do
      before { subject }
      let(:url) { 'https://yande.re/post/index.json?page=1&limit=100&tags=kaichou_wa_maid-sama!' }
      it { expect(JSON.parse(response.body)).to eq data }
    end
  end

  describe '#autocomplete' do
    let!(:tag_1) { create :danbooru_tag, name: 'ffff' }
    let!(:tag_2) { create :danbooru_tag, name: 'testt' }
    let!(:tag_3) { create :danbooru_tag, name: 'zula zula' }

    subject! do
      get :autocomplete,
        params: { search: 'test' },
        xhr: true,
        format: :json
    end

    it do
      expect(collection).to eq [tag_2]
      expect(response).to have_http_status :success
    end
  end
end
