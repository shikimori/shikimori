require 'webmock/rspec'

describe CoubsController do
  describe '#index' do
    before { allow(Coubs::Fetch).to receive(:call).and_return results }

    let(:results) do
      Coub::Results.new(
        coubs: [
          Coub::Entry.new(
            permalink: 'z',
            image_url: 'x',
            categories: ['c'],
            tags: ['v'],
            title: 'b',
            recoubed_permalink: nil,
            author: {
              permalink: 'n',
              name: 'm',
              avatar_template: 'a'
            }
          )
        ],
        iterator: 'zxc'
      )
    end

    subject! { get :index, params: { id: anime.id, iterator: iterator } }
    let(:anime) { create :anime, coub_tags: %w[z x c] }
    let(:iterator) { 'zxc' }

    it do
      expect(Coubs::Fetch)
        .to have_received(:call)
        .with(anime.coub_tags, iterator)
      expect(json).to eq JSON.parse(results.to_json).symbolize_keys
      expect(response).to have_http_status :success
    end
  end

  describe '#autocomplete' do
    let!(:tag_1) { create :coub_tag, name: 'ffff' }
    let!(:tag_2) { create :coub_tag, name: 'testt' }
    let!(:tag_3) { create :coub_tag, name: 'zula zula' }

    subject! { get :autocomplete, params: { search: 'test' } }

    it do
      expect(collection).to eq [tag_2]
      expect(response).to have_http_status :success
    end
  end
end
