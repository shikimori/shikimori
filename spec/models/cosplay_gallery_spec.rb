# frozen_string_literal: true

describe CosplayGallery do
  describe 'topics concern' do
    describe 'associations' do
      it { is_expected.to have_many :topics }
    end

    describe 'callbacks' do
      let(:model) { build :cosplay_gallery }

      before { allow(model).to receive(:generate_topics) }
      before { model.save }

      describe '#generate_topics' do
        it { expect(model).not_to have_received :generate_topics }
      end
    end

    describe 'instance methods' do
      let(:model) { build_stubbed :cosplay_gallery }
      let!(:cosplayer) { create :user, id: User::COSPLAYER_ID }

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
        it { expect(model.topic_user).to eq cosplayer }
      end
    end
  end
end
