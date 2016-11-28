describe Elasticsearch::Create do
  let(:worker) { Elasticsearch::Create.new }

  describe '#perform' do
    before { allow(Elasticsearch::Client.instance).to receive :post }
    subject! { worker.perform anime.id, Anime.name }
    let(:anime) { create :anime }

    it do
      expect(Elasticsearch::Client.instance).to have_received(:post).with(
        "#{Elasticsearch::Create::INDEX}/anime/#{anime.id}",
        Elasticsearch::Data::Anime.call(anime)
      )
    end
  end
end
