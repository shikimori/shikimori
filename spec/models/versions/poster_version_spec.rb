describe Versions::PosterVersion do
  describe '#action' do
    let(:version) { build :poster_version, item_diff: { action: 'upload' } }
    it { expect(version.action).to eq Versions::PosterVersion::Actions[:upload] }
  end

  describe '#apply_changes' do
    include_context :timecop

    let(:poster) { create :poster, is_approved: false, anime: anime }
    let!(:active_poster) { nil }
    let(:anime) { create :anime, desynced: anime_desynced }
    let(:anime_desynced) { [] }

    let(:version) do
      create :poster_version,
        item: poster,
        item_diff: { 'action' => action },
        associated: anime
    end

    subject! { version.apply_changes }

    context 'upload' do
      let(:action) { Versions::PosterVersion::Actions[:upload] }

      context 'no active poster' do
        it do
          expect(poster.reload).to be_is_approved
          expect(anime.reload.desynced).to eq [described_class::FIELD]
        end
      end

      context 'has active poster' do
        let!(:active_poster) { create :poster, is_approved: true, anime: anime }
        it do
          expect(poster.reload).to be_is_approved
          expect(active_poster.reload.deleted_at).to be_within(0.1).of Time.zone.now
          expect(version.reload.item_diff).to eq(
            'action' => 'upload',
            described_class::ITEM_DIFF_KEY_PREV_POSTER_ID => active_poster.id
          )
          expect(anime.reload.desynced).to eq [described_class::FIELD]
        end
      end
    end

    context 'delete' do
      let(:action) { Versions::PosterVersion::Actions[:delete] }
      let(:anime_desynced) { [described_class::FIELD] }

      it do
        expect(poster.reload).to_not be_is_approved
        expect(poster.deleted_at).to be_within(0.1).of Time.zone.now
        expect(anime.reload.desynced).to eq []
        expect(version.reload.item_diff[described_class::ITEM_DIFF_KEY_WAS_DESYNCED]).to eq true
      end
    end
  end

  describe '#rollback_changes' do
    include_context :timecop

    let(:poster) do
      create :poster,
        is_approved: true,
        anime: anime,
        deleted_at: poster_deleted_at
    end
    let(:poster_deleted_at) { nil }
    let!(:prev_poster) { nil }
    let(:anime) { create :anime }
    let(:version) do
      create :poster_version,
        item: poster,
        item_diff: {
          'action' => action,
          described_class::ITEM_DIFF_KEY_PREV_POSTER_ID => prev_poster&.id
        },
        associated: anime
    end

    subject! { version.rollback_changes }

    context 'upload' do
      let(:action) { Versions::PosterVersion::Actions[:upload] }

      context 'had no poster before' do
        it do
          expect(poster.reload.deleted_at).to be_within(0.1).of Time.zone.now
        end
      end

      context 'had poster before' do
        let!(:prev_poster) do
          create :poster,
            is_approved: true,
            anime: anime,
            deleted_at: 1.day.ago
        end

        it do
          expect(poster.reload.deleted_at).to be_within(0.1).of Time.zone.now
          expect(prev_poster.reload.deleted_at).to be_nil
        end
      end
    end

    context 'delete' do
      let(:action) { Versions::PosterVersion::Actions[:delete] }
      let(:poster_deleted_at) { 1.day.ago }

      it do
        expect(poster.reload.deleted_at).to be_nil
      end
    end
  end

  describe '#sweep_deleted' do
    let!(:poster) { create :poster, is_approved: false, anime: anime }
    let(:anime) { create :anime }
    let(:version) do
      create :poster_version,
        item: poster,
        item_diff: { 'action' => action },
        associated: anime
    end

    subject! { version.sweep_deleted }

    context 'upload' do
      let(:action) { Versions::PosterVersion::Actions[:upload] }
      it { expect { poster.reload }.to raise_error ActiveRecord::RecordNotFound }
    end

    context 'delete' do
      let(:action) { Versions::PosterVersion::Actions[:delete] }
      it { expect(poster.reload).to be_persisted }
    end
  end

  describe '#prev_poster' do
    let(:version) do
      build :poster_version,
        item_diff: { described_class::ITEM_DIFF_KEY_PREV_POSTER_ID => poster.id }
    end
    let(:poster) { create :poster, anime: anime }
    let(:anime) { create :anime }
    subject! { version.prev_poster }

    it { is_expected.to eq poster }
  end
end
