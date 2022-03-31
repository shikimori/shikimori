require 'webmock/rspec'

describe CoubsController do
  describe '#index' do
    before { allow(Coubs::Fetch).to receive(:call).and_return results }

    let(:results) do
      Coub::Results.new(
        coubs: [
          Coub::Entry.new(
            permalink: 'z',
            image_template: 'x',
            categories: ['c'],
            tags: ['v'],
            title: 'b',
            recoubed_permalink: nil,
            author: {
              permalink: 'n',
              name: 'm',
              avatar_template: 'a'
            },
            created_at: Time.zone.now.to_s
          )
        ],
        iterator: 'zxc'
      )
    end

    subject! do
      get :index,
        params: {
          id: anime.id,
          iterator: iterator,
          checksum: checksum
        }
    end
    let(:anime) { create :anime, coub_tags: %w[z x c] }
    let(:checksum) { Encoder.instance.checksum iterator }
    let(:iterator) { 'zxc' }

    context 'valid iterator' do
      it do
        expect(Coubs::Fetch)
          .to have_received(:call)
          .with(tags: anime.coub_tags, iterator: iterator)
        expect(assigns(:results)).to eq results
        expect(response).to have_http_status :success
      end
    end

    context 'invalid iterator' do
      let(:iterator) { ['a', :a, nil, ''].sample }
      let(:checksum) { ['a', :a, nil, ''].sample }

      it do
        expect(Coubs::Fetch).to_not have_received :call
        expect(response).to have_http_status 404
      end
    end
  end

  describe '#autocomplete' do
    let!(:tag_1) { create :coub_tag, name: 'ffff' }
    let!(:tag_2) { create :coub_tag, name: 'testt' }
    let!(:tag_3) { create :coub_tag, name: 'zula zula' }

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
