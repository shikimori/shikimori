describe UserHistoryDecorator do
  let(:user_history) do
    build :user_history, {
      target: target,
      action: action,
      value: value,
      prior_value: prior_value
    }
  end
  let(:decorator) { user_history.decorate }

  let(:target) {}
  let(:value) {}
  let(:prior_value) {}

  describe '#format' do
    subject { decorator.format }

    context UserHistoryAction::Add do
      let(:action) { UserHistoryAction::Add }
      it { is_expected.to eq 'Добавлено в список' }
    end

    context UserHistoryAction::Delete do
      let(:action) { UserHistoryAction::Delete }
      it { is_expected.to eq 'Удалено из списка' }
    end

    context UserHistoryAction::Status do
      let(:target) { build :anime }
      let(:value) { UserRate.statuses[:completed] }
      let(:action) { UserHistoryAction::Status }

      it { is_expected.to eq 'Просмотрено' }
    end

    context UserHistoryAction::CompleteWithScore do
      let(:target) { build :anime }
      let(:value) { 8 }
      let(:action) { UserHistoryAction::CompleteWithScore }

      it { is_expected.to eq 'Просмотрено и оценено на <b>8</b>' }
    end

    context UserHistoryAction::CompleteWithScore do
      let(:target) { build :anime }
      let(:value) { 8 }
      let(:action) { UserHistoryAction::CompleteWithScore }

      it { is_expected.to eq 'Просмотрено и оценено на <b>8</b>' }
    end

    context 'episodes, chapters, volumes' do
      let(:action) { UserHistoryAction::Episodes }

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
          let(:action) { UserHistoryAction::Volumes }
          let(:target) { build :manga, volumes: value }
          it { is_expected.to eq 'Прочитана манга' }
        end

        context 'novel' do
          let(:action) { UserHistoryAction::Chapters }
          let(:target) { build :manga, :novel, chapters: value }
          it { is_expected.to eq 'Прочитана новелла' }
        end
      end

      context 'watching reset' do
        let(:value) { 0 }

        context 'anime' do
          let(:action) { UserHistoryAction::Episodes }
          let(:target) { build :anime, episodes: 10 }
          it { is_expected.to eq 'Сброшено число эпизодов' }
        end

        context 'manga' do
          let(:action) { UserHistoryAction::Volumes }
          let(:target) { build :manga, volumes: 10 }
          it { is_expected.to eq 'Сброшено число томов и глав' }
        end
      end

      context 'watching progress' do
        let(:value) { '3,7,8' }
        let(:prior_value) { '2' }

        context 'episodes' do
          let(:action) { UserHistoryAction::Episodes }
          let(:target) { build :anime, episodes: 10 }

          it { is_expected.to eq 'Просмотрены с 3-го по 8-й эпизоды' }
        end

        context 'volumes' do
          let(:action) { UserHistoryAction::Volumes }
          let(:target) { build :manga, volumes: 10 }

          it { is_expected.to eq 'Прочитаны с 3-го по 8-й тома' }
        end

        context 'chapters' do
          let(:action) { UserHistoryAction::Chapters }
          let(:target) { build :manga, chapters: 10 }

          it { is_expected.to eq 'Прочитаны с 3-й по 8-ю главы' }
        end
      end
    end

    context UserHistoryAction::Rate do
      let(:action) { UserHistoryAction::Rate }
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

      context UserHistoryAction::MalAnimeImport do
        let(:action) { UserHistoryAction::MalAnimeImport }
        it { is_expected.to eq 'Импортировано аниме - 101 запись' }
      end

      context UserHistoryAction::ApAnimeImport do
        let(:action) { UserHistoryAction::ApAnimeImport }
        let(:value) { 102 }

        it { is_expected.to eq 'Импортировано аниме - 102 записи' }
      end

      context UserHistoryAction::MalMangaImport do
        let(:action) { UserHistoryAction::MalMangaImport }
        let(:value) { 105 }

        it { is_expected.to eq 'Импортирована манга - 105 записей' }
      end

      context UserHistoryAction::ApMangaImport do
        let(:action) { UserHistoryAction::ApMangaImport }
        it { is_expected.to eq 'Импортирована манга - 101 запись' }
      end
    end

    context UserHistoryAction::Registration do
      let(:action) { UserHistoryAction::Registration }
      it { is_expected.to eq 'Регистрация на сайте' }
    end

    context UserHistoryAction::AnimeHistoryClear do
      let(:action) { UserHistoryAction::AnimeHistoryClear }
      it { is_expected.to eq 'Очистка истории аниме' }
    end

    context UserHistoryAction::MangaHistoryClear do
      let(:action) { UserHistoryAction::MangaHistoryClear }
      it { is_expected.to eq 'Очистка истории манги' }
    end
  end

  describe '#episodes_text' do
    subject { decorator.send :episodes_text, value, prior_value, action }

    let(:action) { UserHistoryAction::Episodes }
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
      let(:action) { UserHistoryAction::Chapters }
      let(:value) { [7] }
      it { is_expected.to eq 'Прочитана 7-я глава' }
    end

    context 'watched two episodes' do
      let(:value) { [7,8] }
      it { is_expected.to eq 'Просмотрены 7-й и 8-й эпизоды' }
    end

    context 'watched three episodes' do
      let(:value) { [7,8,9] }
      it { is_expected.to eq 'Просмотрены 7-й, 8-й и 9-й эпизоды' }
    end

    context 'watched few first episodes' do
      let(:prior_value) { 0 }
      let(:value) { [1,2,3,4] }
      it { is_expected.to eq 'Просмотрены 4 эпизода' }
    end

    context 'watched a few episodes' do
      let(:value) { [7,8,9,10] }
      it { is_expected.to eq 'Просмотрены с 7-го по 10-й эпизоды' }
    end
  end
end
