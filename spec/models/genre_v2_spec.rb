describe GenreV2 do
  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :russian }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:entry_type).in(*Types::GenreV2::EntryType.values) }
    it { is_expected.to enumerize(:kind).in(*Types::GenreV2::Kind.values) }
  end

  describe 'instance methods' do
    describe '#to_param' do
      before do
        subject.id = 123
        subject.name = 'Yaoi hentai'
      end
      its(:to_param) { is_expected.to eq '123-Yaoi-hentai' }
    end

    describe '#anime?, #manga?' do
      before { subject.entry_type = entry_type }

      context 'Anime' do
        let(:entry_type) { Types::GenreV2::EntryType['Anime'] }

        its(:anime?) { is_expected.to eq true }
        its(:manga?) { is_expected.to eq false }
      end

      context 'Manga' do
        let(:entry_type) { Types::GenreV2::EntryType['Manga'] }

        its(:anime?) { is_expected.to eq false }
        its(:manga?) { is_expected.to eq true }
      end
    end

    describe '#title' do
      subject { genre_v2.title ru_case:, user: }

      let(:ru_case) { :subjective }
      let(:user) { nil }

      let(:genre_v2) { build :genre_v2, name:, russian:, entry_type: }
      let(:entry_type) { Types::GenreV2::EntryType['Anime'] }
      let(:name) { 'Romance' }
      let(:russian) { '123' }

      context 'anime' do
        context 'Magic' do
          let(:name) { 'Magic' }
          it { is_expected.to eq 'Аниме про магию' }
        end

        context 'Shounen' do
          let(:name) { 'Shounen' }
          it { is_expected.to eq 'Сёнен аниме' }
        end

        context 'Romance' do
          let(:name) { 'Romance' }
          it { is_expected.to eq 'Романтические аниме про любовь' }
        end

        context 'CGDCT' do
          let(:name) { 'CGDCT' }
          let(:russian) { 'CGDCT' }
          it { is_expected.to eq 'CGDCT аниме' }
        end
      end

      context 'manga' do
        let(:entry_type) { Types::GenreV2::EntryType['Manga'] }

        context 'Magic' do
          let(:name) { 'Magic' }
          it { is_expected.to eq 'Манга про магию' }
        end

        context 'Shounen' do
          let(:name) { 'Shounen' }
          it { is_expected.to eq 'Сёнен манга' }
        end

        context 'Romance' do
          let(:name) { 'Romance' }
          it { is_expected.to eq 'Романтическая манга про любовь' }
        end
      end

      context 'genitive case' do
        let(:ru_case) { :genitive }
        it { expect { subject }.to raise_error ArgumentError }
      end

      context 'default title' do
        let(:genre_v2) { build :genre_v2, name:, entry_type:, russian: 'Безумие' }
        let(:name) { 'Dementia' }

        it { is_expected.to eq 'Аниме жанра безумие' }
      end
    end
  end

  describe 'permissions' do
    let(:genre) { build_stubbed :genre_v2 }
    let(:user) { build_stubbed :user, :user }
    subject { Ability.new user }

    context 'genre_moderator' do
      let(:user) { build_stubbed :user, :genre_moderator }

      it { is_expected.to be_able_to :read, genre }
      it { is_expected.to be_able_to :tooltip, genre }
      it { is_expected.to be_able_to :edit, genre }
      it { is_expected.to be_able_to :update, genre }
    end

    context 'forum_moderator' do
      let(:user) { build_stubbed :user, :forum_moderator }

      it { is_expected.to be_able_to :read, genre }
      it { is_expected.to be_able_to :tooltip, genre }
      it { is_expected.to_not be_able_to :edit, genre }
      it { is_expected.to_not be_able_to :update, genre }
    end

    context 'user' do
      it { is_expected.to be_able_to :read, genre }
      it { is_expected.to be_able_to :tooltip, genre }
      it { is_expected.to_not be_able_to :edit, genre }
      it { is_expected.to_not be_able_to :update, genre }
    end

    context 'guest' do
      let(:user) { nil }

      it { is_expected.to be_able_to :read, genre }
      it { is_expected.to be_able_to :tooltip, genre }
      it { is_expected.to_not be_able_to :edit, genre }
      it { is_expected.to_not be_able_to :update, genre }
    end
  end
end
