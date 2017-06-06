describe Elasticsearch::Destroy do
  let(:worker) { Elasticsearch::Destroy.new }

  describe '#perform' do
    before { allow(Elasticsearch::Client.instance).to receive :delete }
    subject! { worker.perform anime.id, Anime.name }
    let(:anime) { create :anime }

    it do
      expect(Elasticsearch::Client.instance).to have_received(:delete).with(
        "#{Elasticsearch::Create::INDEX}_animes/animes/#{anime.id}"
      )
    end
  end
end
