describe Animes::Query do
  describe '#fetch' do
    subject do
      described_class.fetch(
        scope: scope,
        params: params,
        user: user,
        is_apply_excludes: is_apply_excludes
      )
    end
    let(:scope) { [Anime.all, Anime].sample }
    let(:params) { {} }
    let(:user) { nil }
    let(:is_apply_excludes) { true }

    let(:anime) { create :anime }
    let(:anime_2) { create :anime }

    let(:animes_scope) { Anime.where id: anime.id }

    context 'no params' do
      it { is_expected.to eq Anime.all.to_a }
    end

    context '#by_achievement' do
      let(:params) { { achievement: 'zzz' } }
      before do
        allow(Animes::Filters::ByAchievement)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_duration' do
      let(:params) { { duration: 'zzz' } }
      before do
        allow(Animes::Filters::ByDuration)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_exclude_ids' do
      let!(:anime_1) { create :anime }
      let!(:anime_2) { create :anime }
      let!(:anime_3) { create :anime }

      let(:scope) { Anime.order :id }
      let(:params) do
        {
          exclude_ids: [
            "#{anime_3.id},#{anime_2.id}",
            [anime_3.id, anime_2.id]
          ].sample
        }
      end

      it { is_expected.to eq [anime_1] }
    end

    context '#by_franchise' do
      let(:params) { { franchise: 'zzz' } }
      before do
        allow(Animes::Filters::ByFranchise)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_genre' do
      let(:params) { { genre: 'zzz' } }
      before do
        allow(Animes::Filters::ByGenre)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_ids' do
      let!(:anime_1) { create :anime }
      let!(:anime_2) { create :anime }
      let!(:anime_3) { create :anime }

      let(:scope) { Anime.order :id }
      let(:params) do
        {
          ids: [
            "#{anime_3.id},#{anime_2.id}",
            [anime_3.id, anime_2.id]
          ].sample
        }
      end

      it { is_expected.to eq [anime_2, anime_3] }
    end

    context '#by_kind' do
      let(:params) { { kind: 'zzz' } }
      before do
        allow(Animes::Filters::ByKind)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_licensor' do
      let(:params) { { licensor: 'zzz' } }
      before do
        allow(Animes::Filters::ByLicensor)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_user_list' do
      let(:params) { { mylist: 'zzz' } }
      let(:user) { seed :user }
      before do
        allow(Animes::Filters::ByUserList)
          .to receive(:call)
          .with(any_args, 'zzz', user)
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_desynced' do
      let(:params) { { desynced: 'zzz' } }
      let(:user) { seed :user }
      before do
        allow(Animes::Filters::ByDesynced)
          .to receive(:call)
          .with(any_args, 'zzz', user)
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_publisher' do
      let(:params) { { publisher: 'zzz' } }
      before do
        allow(Animes::Filters::ByPublisher)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_rating' do
      let(:params) { { rating: 'zzz' } }
      before do
        allow(Animes::Filters::ByRating)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_score' do
      let(:params) { { score: 'zzz' } }
      before do
        allow(Animes::Filters::ByScore)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_season' do
      let(:params) { { season: 'zzz' } }
      before do
        allow(Animes::Filters::BySeason)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_status' do
      let(:params) { { status: 'zzz' } }
      before do
        allow(Animes::Filters::ByStatus)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_studio' do
      let(:params) { { studio: 'zzz' } }
      before do
        allow(Animes::Filters::ByStudio)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    describe '#exclude_hentai' do
      before do
        allow_any_instance_of(described_class)
          .to receive(:exclude_hentai)
          .and_return(described_class.new(Anime.none))
      end

      it { is_expected.to eq [] }

      describe 'Animes::Filters::Policy.exclude_hentai?' do
        before do
          allow(Animes::Filters::Policy)
            .to receive(:exclude_hentai?)
            .with(params)
            .and_return is_exclude_hentai
        end

        context 'true' do
          let(:is_exclude_hentai) { true }
          it { is_expected.to eq [] }
        end

        context 'false' do
          let(:is_exclude_hentai) { false }
          it { is_expected.to eq [anime] }
        end
      end

      context 'is_apply_excludes: false' do
        let(:is_apply_excludes) { false }
        it { is_expected.to eq [anime] }
      end
    end

    describe '#exclude_music' do
      before do
        allow_any_instance_of(described_class)
          .to receive(:exclude_music)
          .and_return(described_class.new(Anime.none))
      end

      it { is_expected.to eq [] }

      describe 'Animes::Filters::Policy.exclude_music?' do
        before do
          allow(Animes::Filters::Policy)
            .to receive(:exclude_music?)
            .with(params)
            .and_return is_exclude_music
        end

        context 'true' do
          let(:is_exclude_music) { true }
          it { is_expected.to eq [] }
        end

        context 'false' do
          let(:is_exclude_music) { false }
          it { is_expected.to eq [anime] }
        end
      end

      context 'is_apply_excludes: false' do
        let(:is_apply_excludes) { false }
        it { is_expected.to eq [anime] }
      end
    end

    context '#order_by' do
      let(:params) { { order: 'zzz' } }
      before do
        allow(Animes::Filters::OrderBy)
          .to receive(:call)
          .with(any_args, 'zzz')
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end

    context '#by_search' do
      let(:params) { { search: 'zzz' } }

      before do
        allow(Search::Anime).to receive(:call)
          .and_return animes_scope
      end

      it { is_expected.to eq [anime] }
    end
  end

  describe '#exclude_ai_genres' do
    let!(:common_anime) { create :anime }
    let!(:anime_yaoi) { create :anime, genre_ids: [yaoi.id] }
    let!(:anime_hentai) { create :anime, genre_ids: [hentai.id] }
    let!(:anime_yuri) { create :anime, genre_ids: [yuri.id] }
    let!(:anime_shounen_ai) { create :anime, genre_ids: [shounen_ai.id] }
    let!(:anime_shoujo_ai) { create :anime, genre_ids: [shoujo_ai.id] }

    let(:yaoi) { create :genre, id: Genre::YAOI_IDS.sample }
    let(:yuri) { create :genre, id: Genre::YURI_IDS.sample }
    let(:hentai) { create :genre, id: Genre::HENTAI_IDS.sample }
    let(:shounen_ai) { create :genre, id: Genre::SHOUNEN_AI_IDS.sample }
    let(:shoujo_ai) { create :genre, id: Genre::SHOUJO_AI_IDS.sample }

    subject { described_class.new(Anime.order(:id)).exclude_ai_genres sex }

    context 'male' do
      let(:sex) { 'male' }
      it { is_expected.to eq [common_anime, anime_hentai, anime_yuri, anime_shoujo_ai] }
    end

    context 'female' do
      let(:sex) { 'female' }
      it { is_expected.to eq [common_anime, anime_yaoi, anime_shounen_ai] }
    end

    context 'not specified' do
      let(:sex) { ['', nil].sample }
      it { is_expected.to eq [common_anime] }
    end
  end
end
