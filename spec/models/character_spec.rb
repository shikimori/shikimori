# frozen_string_literal: true

describe Character do
  describe 'relations' do
    it { is_expected.to have_many :person_roles }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many :persons }

    it { is_expected.to have_many :persons }
    it { is_expected.to have_many :japanese_roles }
    it { is_expected.to have_many :seyu }

    it { is_expected.to have_attached_file :image }

    it { is_expected.to have_many :cosplay_gallery_links }
    it { is_expected.to have_many :cosplay_galleries }
  end

  describe 'topics concern' do
    describe 'associations' do
      it { is_expected.to have_many :topics }
    end

    describe 'callbacks' do
      let(:model) { build :character }

      before { allow(model).to receive(:generate_topics) }
      before { model.save }

      describe '#generate_topics' do
        it { expect(model).not_to have_received :generate_topics }
      end
    end

    describe 'instance methods' do
      let(:model) { create :character }

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
        subject { model.send :topic_auto_generated? }
        it { is_expected.to eq false }
      end

      describe '#topic_user' do
        subject { model.send :topic_user }
        it { is_expected.to eq BotsService.get_poster }
      end
    end
  end
end
