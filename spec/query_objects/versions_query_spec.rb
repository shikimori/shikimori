describe VersionsQuery do
  let(:query) { described_class.by_item anime }
  let(:anime) { create :anime }

  describe '.by_item' do
    it { expect(query).to eq [] }

    describe 'deleted' do
      let!(:pending) { create :version, item: anime }
      let!(:deleted) { create :version, item: anime, state: 'deleted' }

      it { expect(query).to eq [pending] }
    end

    describe 'another entry' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :version, item: create(:anime) }

      it { expect(query).to eq [version_1] }
    end

    describe 'associated' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :version, associated: anime }

      it { expect(query).to eq [version_2, version_1] }
    end

    describe 'ordering' do
      let!(:version_1) { create :version, item: anime, created_at: 2.days.ago }
      let!(:version_2) { create :version, item: anime, created_at: 1.day.ago }

      it { expect(query).to eq [version_2, version_1] }
    end
  end

  describe '.by_type' do
    let(:query) { described_class.by_type Anime.name }

    it { expect(query).to eq [] }

    describe 'deleted' do
      let!(:pending) { create :version, item: anime }
      let!(:deleted) { create :version, item: anime, state: 'deleted' }

      it { expect(query).to eq [pending] }
    end

    describe 'another entry' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :version, item: create(:anime) }

      it { expect(query).to eq [version_2, version_1] }
    end

    describe 'another type' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :version, item: create(:manga) }

      it { expect(query).to eq [version_1] }
    end

    describe 'associated' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :version, associated: anime }

      it { expect(query).to eq [version_2, version_1] }
    end

    describe 'ordering' do
      let!(:version_1) { create :version, item: anime, created_at: 2.days.ago }
      let!(:version_2) { create :version, item: anime, created_at: 1.day.ago }

      it { expect(query).to eq [version_2, version_1] }
    end
  end

  describe '#by_field' do
    describe 'deleted' do
      let!(:pending) { create :version, item: anime }
      let!(:deleted) { create :version, item: anime, state: 'deleted' }

      it { expect(query.by_field :russian).to eq [pending] }
    end

    describe 'another entry' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :version, item: create(:anime) }

      it { expect(query.by_field :russian).to eq [version_1] }
    end

    describe 'another field' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) do
        create :version, item: anime, item_diff: { 'name' => ['a', 'b'] }
      end

      it { expect(query.by_field :russian).to eq [version_1] }
    end

    describe 'videos + associated' do
      let!(:version_1) { create :version, item: anime, item_diff: { 'videos' => [] } }
      let!(:version_2) { create :video_version, item: video, associated: anime }
      let(:video) { create :video, anime: anime }

      it { expect(query.by_field :videos).to eq [version_2, version_1] }

      context 'another entry' do
        let!(:version_3) { create :video_version, item: video_2, associated: anime_2 }
        let(:video_2) { create :video, anime: anime_2 }
        let(:anime_2) { create :anime }

        it { expect(query.by_field :videos).to eq [version_2, version_1] }
      end
    end

    describe 'poster + associated' do
      let!(:version_1) { create :version, item: anime }
      let!(:version_2) { create :poster_version, item: poster, associated: anime }
      let(:poster) { create :poster, anime: anime }

      it { expect(query.by_field :poster).to eq [version_2] }
    end

    describe 'ordering' do
      let!(:version_1) { create :version, item: anime, created_at: 2.days.ago }
      let!(:version_2) { create :version, item: anime, created_at: 1.day.ago }

      it { expect(query.by_field :russian).to eq [version_2, version_1] }
    end
  end

  describe '#authors' do
    let(:author_1) { create :user }
    let(:author_2) { create :user }
    let(:diff) { { description_ru: ['a', 'b'] } }

    describe 'accepted' do
      let!(:pending) { create :version, item_diff: diff, item: anime }
      let!(:accepted) do
        create :version, :accepted,
          user: author_1,
          item_diff: diff,
          item: anime
      end
      let!(:taken) do
        create :version, :taken,
          item_diff: diff,
          item: anime
      end
      let!(:deleted) do
        create :version, :deleted,
          item_diff: diff,
          item: anime
      end

      it { expect(query.authors :description_ru).to eq [author_1] }
    end

    describe 'another entry' do
      let!(:accepted_1) do
        create :version, :accepted,
          user: author_1,
          item_diff: diff,
          item: anime
      end
      let!(:accepted_2) do
        create :version, :accepted,
          user: author_2,
          item_diff: diff,
          item: create(:anime)
      end

      it { expect(query.authors :description_ru).to eq [author_1] }
    end

    describe 'another field' do
      let!(:accepted_1) do
        create :version, :accepted,
          user: author_1,
          item_diff: diff,
          item: anime
      end
      let!(:accepted_2) do
        create :version, :accepted,
          user: author_2,
          item_diff: { name: [1, 2] },
          item: anime
      end

      it { expect(query.authors :description_ru).to eq [author_1] }
    end

    describe 'ordering' do
      let!(:accepted_1) do
        create :version, :accepted,
          user: author_1,
          item_diff: diff,
          item: anime,
          created_at: 2.days.ago
      end
      let!(:accepted_2) do
        create :version, :accepted,
          user: author_2,
          item_diff: diff,
          item: anime,
          created_at: 1.day.ago
      end

      it { expect(query.authors :description_ru).to eq [author_1, author_2] }
    end

    context 'screenshots' do
      let!(:upload) do
        create :version, :accepted,
          user: author_1,
          item_diff: {
            action: Versions::ScreenshotsVersion::Actions[:upload],
            screenshots: ['a', 'b']
          },
          item: anime
      end
      let!(:delete) do
        create :version, :accepted,
          user: author_2,
          item_diff: {
            action: Versions::ScreenshotsVersion::Actions[:delete],
            screenshots: ['a', 'b']
          },
          item: anime
      end
      let!(:reposition) do
        create :version, :accepted,
          user: author_2,
          item_diff: {
            action: Versions::ScreenshotsVersion::Actions[:reposition],
            screenshots: ['a', 'b']
          },
          item: anime
      end

      it { expect(query.authors :screenshots).to eq [author_1] }
    end

    context 'videos' do
      let!(:upload) do
        create :version, :accepted,
          user: author_1,
          item_diff: {
            action: Versions::VideoVersion::Actions[:upload],
            videos: ['a', 'b']
          },
          item: anime
      end
      let!(:delete) do
        create :version, :accepted,
          user: author_2,
          item_diff: {
            action: Versions::VideoVersion::Actions[:delete],
            videos: ['a', 'b']
          },
          item: anime
      end

      it { expect(query.authors :videos).to eq [author_1] }
    end
  end
end
