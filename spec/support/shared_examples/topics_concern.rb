shared_examples :topics_concern do |db_entry|
  describe 'topics concern' do
    describe 'associations' do
      it { is_expected.to have_many(:all_topics).dependent :destroy }
      it { is_expected.to have_many :topics }
      it { is_expected.to have_many :news_topics }
    end

    describe 'instance methods' do
      let(:model) { build_stubbed db_entry }

      describe '#generate_topics' do
        let(:topics) { model.topics }
        before { model.generate_topics :en }

        it do
          expect(topics).to have(1).item
          expect(topics.first.locale).to eq 'en'
        end
      end

      describe '#topic' do
        let(:topic) { model.topic locale }
        before { model.generate_topics :ru }

        context 'with topic for locale' do
          let(:locale) { :ru }
          it do
            expect(topic).to be_present
            expect(topic.locale).to eq locale
          end
        end

        context 'without topic for locale' do
          let(:locale) { :en }
          it { expect(topic).to be_nil }
        end
      end

      describe '#maybe_topic' do
        let(:topic) { model.maybe_topic locale }
        before { model.generate_topics :ru }

        context 'with topic for locale' do
          let(:locale) { :ru }
          it do
            expect(topic).to be_present
            expect(topic.locale).to eq locale
          end
        end

        context 'without topic for locale' do
          let(:locale) { :en }
          it do
            expect(topic).to be_present
            expect(topic).to be_instance_of NoTopic
            expect(topic.linked).to eq model
          end
        end
      end

      describe '#topic_user' do
        let(:poster) do
          case model
            when DbEntry then BotsService.get_poster
            when Club then model.owner
            else model.user
          end
        end
        it { expect(model.topic_user).to eq poster }
      end
    end
  end
end
