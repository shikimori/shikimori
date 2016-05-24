# frozen_string_literal: true

describe Person do
  describe 'relations' do
    it { is_expected.to have_many :person_roles }
    it { is_expected.to have_many :animes }
    it { is_expected.to have_many :mangas }
    it { is_expected.to have_many :characters }

    it { is_expected.to have_attached_file :image }
  end

  describe 'topics concern' do
    describe 'associations' do
      it { is_expected.to have_many :topics }
    end

    describe 'instance methods' do
      let(:model) { create :person }

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
