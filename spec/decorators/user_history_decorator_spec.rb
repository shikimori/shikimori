describe UserHistoryDecorator do
  let(:user_history) do
    build :user_history,
      anime: (target if target&.anime?),
      manga: (target if target&.kinda_manga?),
      action: action,
      value: value,
      prior_value: prior_value
  end
  let(:decorator) { user_history.decorate }

  let(:action) { nil }
  let(:target) { nil }
  let(:value) { nil }
  let(:prior_value) { nil }

  describe '#target' do
    it { expect(decorator.target).to be_nil }

    context 'anime' do
      let(:target) { build :anime }
      it { expect(decorator.target).to eq target }
    end

    context 'manga' do
      let(:target) { build :manga }
      it { expect(decorator.target).to eq target }
    end
  end

  describe '#format' do
    subject { decorator.format }

    context UserHistoryAction::ADD do
      let(:action) { UserHistoryAction::ADD }
      it { is_expected.to eq 'Добавлено в список' }
    end

    context UserHistoryAction::DELETE do
      let(:action) { UserHistoryAction::DELETE }
      it { is_expected.to eq 'Удалено из списка' }
    end

    context UserHistoryAction::STATUS do
      let(:target) { build :anime }
      let(:value) { UserRate.statuses[:completed] }
      let(:action) { UserHistoryAction::STATUS }

      it { is_expected.to eq 'Просмотрено' }
    end

    context UserHistoryAction::COMPLETE_WITH_SCORE do
      let(:target) { build :anime }
      let(:value) { 8 }
      let(:action) { UserHistoryAction::COMPLETE_WITH_SCORE }

      it { is_expected.to eq 'Просмотрено и оценено на <b>8</b>' }
    end

    context UserHistoryAction::COMPLETE_WITH_SCORE do
      let(:target) { build :anime }
      let(:value) { 8 }
      let(:action) { UserHistoryAction::COMPLETE_WITH_SCORE }

      it { is_expected.to eq 'Просмотрено и оценено на <b>8</b>' }
    end

    context 'episodes, chapters, volumes' do
      let(:action) { UserHistoryAction::EPISODES }

      context 'finished watching' do
        let(:value) { 10 }

        context 'movie' do
          let(:value) { 1 }
          let(:target) { build :anime, :movie, episodes: value }
          it { is_expected.to eq 'Просмотрен фильм' }
        end

        context 'anime' do
          let(:target) { build :anime, episodes: value }
          it { is_expected.to eq 'Просмотрены все эпизоды' }
        end

        context 'manga' do
          let(:action) { UserHistoryAction::VOLUMES }
          let(:target) { build :manga, volumes: value }
          it { is_expected.to eq 'Прочитана манга' }
        end

        context 'novel' do
          let(:action) { UserHistoryAction::CHAPTERS }
          let(:target) { build :manga, :novel, chapters: value }
          it { is_expected.to eq 'Прочитана новелла' }
        end
      end

      context 'watching reset' do
        let(:value) { 0 }

        context 'anime' do
          let(:action) { UserHistoryAction::EPISODES }
          let(:target) { build :anime, episodes: 10 }
          it { is_expected.to eq 'Сброшено число эпизодов' }
        end

        context 'manga' do
          let(:action) { UserHistoryAction::VOLUMES }
          let(:target) { build :manga, volumes: 10 }
          it { is_expected.to eq 'Сброшено число томов и глав' }
        end
      end

      context 'watching progress' do
        let(:value) { '3,7,8' }
        let(:prior_value) { '2' }

        context 'episodes' do
          let(:action) { UserHistoryAction::EPISODES }
          let(:target) { build :anime, episodes: 10 }

          it { is_expected.to eq 'Просмотрены с 3-го по 8-й эпизоды' }
        end

        context 'volumes' do
          let(:action) { UserHistoryAction::VOLUMES }
          let(:target) { build :manga, volumes: 10 }

          it { is_expected.to eq 'Прочитаны с 3-го по 8-й тома' }
        end

        context 'chapters' do
          let(:action) { UserHistoryAction::CHAPTERS }
          let(:target) { build :manga, chapters: 10 }

          it { is_expected.to eq 'Прочитаны с 3-й по 8-ю главы' }
        end
      end
    end

    context UserHistoryAction::RATE do
      let(:action) { UserHistoryAction::RATE }
      let(:value) { 8 }

      context 'cancelled' do
        let(:value) { 0 }
        it { is_expected.to eq 'Отменена оценка' }
      end

      context 'changed' do
        let(:prior_value) { 3 }
        it { is_expected.to eq 'Изменена оценка c <b>3</b> на <b>8</b>' }
      end

      context 'rated' do
        it { is_expected.to eq 'Оценено на <b>8</b>' }
      end
    end

    context 'import' do
      let(:value) { 101 }

      context UserHistoryAction::MAL_ANIME_IMPORT do
        let(:action) { UserHistoryAction::MAL_ANIME_IMPORT }
        it { is_expected.to eq 'Импортировано аниме - 101 запись' }
      end

      context UserHistoryAction::AP_ANIME_IMPORT do
        let(:action) { UserHistoryAction::AP_ANIME_IMPORT }
        let(:value) { 102 }

        it { is_expected.to eq 'Импортировано аниме - 102 записи' }
      end

      context UserHistoryAction::MAL_MANGA_IMPORT do
        let(:action) { UserHistoryAction::MAL_MANGA_IMPORT }
        let(:value) { 105 }

        it { is_expected.to eq 'Импортирована манга - 105 записей' }
      end

      context UserHistoryAction::AP_MANGA_IMPORT do
        let(:action) { UserHistoryAction::AP_MANGA_IMPORT }
        it { is_expected.to eq 'Импортирована манга - 101 запись' }
      end
    end

    context UserHistoryAction::REGISTRATION do
      let(:action) { UserHistoryAction::REGISTRATION }
      it { is_expected.to eq 'Регистрация на сайте' }
    end

    context UserHistoryAction::ANIME_HISTORY_CLEAR do
      let(:action) { UserHistoryAction::ANIME_HISTORY_CLEAR }
      it { is_expected.to eq 'Очистка истории аниме' }
    end

    context UserHistoryAction::MANGA_HISTORY_CLEAR do
      let(:action) { UserHistoryAction::MANGA_HISTORY_CLEAR }
      it { is_expected.to eq 'Очистка истории манги' }
    end
  end

  describe '#episodes_text' do
    subject { decorator.send :episodes_text, value, prior_value, action }

    let(:action) { UserHistoryAction::EPISODES }
    let(:prior_value) { 6 }

    context 'changed episodes to lesser value' do
      let(:value) { [5] }
      it { is_expected.to eq 'Просмотрено 5 эпизодов' }
    end

    context 'watched one episode' do
      let(:value) { [9] }
      it { is_expected.to eq 'Просмотрен 9-й эпизод' }
    end

    context 'read one chapter' do
      let(:action) { UserHistoryAction::CHAPTERS }
      let(:value) { [7] }
      it { is_expected.to eq 'Прочитана 7-я глава' }
    end

    context 'watched two episodes' do
      let(:value) { [7, 8] }
      it { is_expected.to eq 'Просмотрены 7-й и 8-й эпизоды' }
    end

    context 'watched three episodes' do
      let(:value) { [7, 8, 9] }
      it { is_expected.to eq 'Просмотрены 7-й, 8-й и 9-й эпизоды' }
    end

    context 'watched few first episodes' do
      let(:prior_value) { 0 }
      let(:value) { [1, 2, 3, 4] }
      it { is_expected.to eq 'Просмотрены 4 эпизода' }
    end

    context 'watched a few episodes' do
      let(:value) { [7, 8, 9, 10] }
      it { is_expected.to eq 'Просмотрены с 7-го по 10-й эпизоды' }
    end
  end
end
