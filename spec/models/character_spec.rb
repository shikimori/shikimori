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

    describe 'instance methods' do
      let(:model) { create :character }

      describe '#generate_topics' do
        let(:topics) { model.topics }
        before { model.generate_topics :en }

        it do
          expect(topics).to have(1).item
          expect(topics.first.locale).to eq 'en'
        end
      end

      describe '#topic_user' do
        it { expect(model.topic_user).to eq BotsService.get_poster }
      end
    end
  end
end
