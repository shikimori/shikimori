describe DbImport::MalPoster do
  include_context :timecop

  let(:service) do
    described_class.new(
      entry: entry,
      image_url: image_url
    )
  end
  let(:entry) { create :anime }
  let(:image_url) { 'https://cdn.myanimelist.net/images/anime/3/72078l.jpg' }
  let!(:prev_poster) { create :poster, anime: entry }

  before do
    allow(DbImport::PosterPolicy)
      .to receive(:new)
      .with(entry: entry, image_url: image_url)
      .and_return(poster_policy)

    if is_nil_import
      allow(service).to receive(:download_image).and_return nil
    end
  end
  let(:poster_policy) { double need_import?: need_import }
  let(:is_nil_import) { false }
  subject! { service.call }

  context 'need import', :vcr do
    let(:need_import) { true }

    it do
      expect(entry.reload.poster).to_not eq prev_poster
      expect(entry.poster).to be_persisted
      expect(entry.poster.image).to be_exists
      expect(entry.poster.mal_url).to eq image_url
      expect(prev_poster.reload.deleted_at).to be_within(0.1).of Time.zone.now
    end

    describe 'broken import does not delete prev poster' do
      let(:is_nil_import) { true }
      it do
        expect(entry.reload.poster).to eq prev_poster
        expect(prev_poster.reload.deleted_at).to be_nil
      end
    end
  end

  context 'dont need import' do
    let(:need_import) { false }
    it { expect(entry.image).to_not be_present }
  end
end
