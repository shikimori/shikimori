# frozen_string_literal: true

describe Manga do
  describe 'relations' do
    it { is_expected.to have_and_belong_to_many :genres }
    it { is_expected.to have_and_belong_to_many :publishers }

    it { is_expected.to have_many :person_roles }
    it { is_expected.to have_many :characters }
    it { is_expected.to have_many :people }

    it { is_expected.to have_many :rates }

    it { is_expected.to have_many :related }
    it { is_expected.to have_many :related_mangas }
    it { is_expected.to have_many :related_animes }

    it { is_expected.to have_many :similar }

    it { is_expected.to have_many :user_histories }

    it { is_expected.to have_many :cosplay_gallery_links }
    it { is_expected.to have_many :cosplay_galleries }

    it { is_expected.to have_many :reviews }

    it { is_expected.to have_attached_file :image }

    it { is_expected.to have_many :recommendation_ignores }
    it { is_expected.to have_many :manga_chapters }

    it { is_expected.to have_many :name_matches }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
  end

  describe 'enumerize' do
    it { is_expected.to enumerize(:kind).in :doujin, :manga, :manhua, :manhwa, :novel, :one_shot }
    it { is_expected.to enumerize(:status).in :anons, :ongoing, :released }
  end

  describe 'scopes' do
    before do
      [nil, 'rm_katana', 'am_love_knot'].each do |read_manga_id|
        create :manga, read_manga_id: read_manga_id
      end
    end

    describe '#read_manga' do
      it { expect(Manga.read_manga).to have(1).item }
      it { expect(Manga.read_manga.first.read_manga_id).to eq 'rm_katana' }
    end

    describe '#read_manga_adult' do
      it { expect(Manga.read_manga_adult).to have(1).item }
      it { expect(Manga.read_manga_adult.first.read_manga_id).to eq 'am_love_knot' }
    end
  end

  describe 'topics concern' do
    describe 'associations' do
      it { is_expected.to have_many :topics }
    end

    describe 'callbacks' do
      let(:model) { build :manga }

      before { allow(model).to receive(:generate_topics) }
      before { model.save }

      describe '#generate_topics' do
        it { expect(model).not_to have_received :generate_topics }
      end
    end

    describe 'instance methods' do
      let(:model) { build_stubbed :manga }

      describe '#generate_topics' do
        let(:topics) { model.topics.order(:locale) }
        before { model.generate_topics }

        it do
          expect(topics).to have(2).items
          expect(topics.first.locale).to eq 'en'
          expect(topics.second.locale).to eq 'ru'
        end
      end

      describe '#topic_auto_generated' do
        it { expect(model.topic_auto_generated?).to eq false }
      end

      describe '#topic_user' do
        it { expect(model.topic_user).to eq BotsService.get_poster }
      end
    end
  end
end
