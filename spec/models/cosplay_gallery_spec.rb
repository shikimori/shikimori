# frozen_string_literal: true

describe CosplayGallery do
  describe 'topics concern' do
    describe 'associations' do
      it { is_expected.to have_many :topics }
    end

    describe 'instance methods' do
      let(:model) { build_stubbed :cosplay_gallery }
      let!(:cosplayer) { create :user, id: User::COSPLAYER_ID }

      describe '#generate_topics' do
        let(:topics) { model.topics }
        before { model.generate_topics [:en, :ru] }

        it do
          expect(topics).to have(2).items
          expect(topics.first.locale).to eq 'ru'
          expect(topics.second.locale).to eq 'en'
        end
      end

      describe '#topic' do
        let(:topic) { model.topic locale }
        before { model.generate_topics [:en, :ru] }

        context 'ru topic' do
          let(:locale) { :ru }
          it do
            expect(topic).to be_present
            expect(topic.locale).to eq locale.to_s
          end
        end

        context 'en topic' do
          let(:locale) { :en }
          it do
            expect(topic).to be_present
            expect(topic.locale).to eq locale.to_s
          end
        end
      end

      describe '#topic_user' do
        it { expect(model.topic_user).to eq cosplayer }
      end
    end
  end
end
