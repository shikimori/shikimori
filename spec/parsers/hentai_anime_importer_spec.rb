require 'spec_helper'

describe HentaiAnimeImporter do
  let(:importer) { HentaiAnimeImporter.new }

  describe :import do
    subject(:import) { importer.import pages: pages, ids: ids, last_episodes: last_episodes }
    let!(:anime) { create :anime, name: 'Sextra Credit', censored: true }
    let(:identifier) { 'sextra_credit' }
    let(:last_episodes) { false }
    let(:pages) { [0] }
    let(:ids) { [] }
    before { HentaiAnimeParser.any_instance.stub(:fetch_page_links).and_return [identifier] }

    let(:videos) { AnimeVideo.where anime_id: anime.id }
    it { expect{subject}.to change(videos, :count).by 4 }
  end
end
