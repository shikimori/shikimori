describe Elasticsearch::Update do
  let(:worker) { Elasticsearch::Update.new }

  describe '#perform' do
    before { allow(Elasticsearch::ClientOld.instance).to receive :put }
    subject! { worker.perform anime.id, Anime.name }
    let(:anime) { create :anime }

    it do
      expect(Elasticsearch::ClientOld.instance).to have_received(:put).with(
        "#{Elasticsearch::Create::INDEX}_animes/animes/#{anime.id}",
        Elasticsearch::Data::Anime.call(anime)
      )
    end
  end
end
