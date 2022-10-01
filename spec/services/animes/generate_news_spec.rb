# frozen_string_literal: true

describe Animes::GenerateNews do
  let(:service) { Animes::GenerateNews.new anime, old_status, new_status }
  let(:anime) { create :anime, status: new_status }

  context 'status not changed' do
    let(:old_status) { :anons }
    let(:new_status) { :anons }

    it 'does not generate news topics' do
      expect { service.call }.to raise_error ArgumentError, 'status not changed'
      expect(anime.news_topics).to be_empty
    end
  end

  context 'status changed' do
    subject! { service.call }

    describe 'anons news topics' do
      context 'anime is created' do
        let(:old_status) { nil }
        let(:new_status) { :anons }

        it 'generates 2 anons news topics for both locales' do
          expect(anime.anons_news_topics).to have(2).items
        end
      end

      context 'rollbacked from ongoing to anons' do
        let(:old_status) { :ongoing }
        let(:new_status) { :anons }

        it 'does not generate anons news topics' do
          expect(anime.anons_news_topics).to be_empty
        end
      end
    end

    describe 'ongoing news topics' do
      context 'status changed from anons to ongoing' do
        let(:old_status) { :anons }
        let(:new_status) { :ongoing }

        it 'generates 2 ongoing news topics for both locales' do
          expect(anime.ongoing_news_topics).to have(2).items
        end
      end

      context 'rollbacked from released to ongoing' do
        let(:old_status) { :released }
        let(:new_status) { :ongoing }

        it 'does not generate ongoing news topics' do
          expect(anime.ongoing_news_topics).to be_empty
        end
      end
    end

    describe 'released news topics' do
      let(:anime) do
        create :anime,
          status: new_status,
          released_on: released_on,
          aired_on: aired_on
      end

      let(:old_status) { :ongoing }
      let(:new_status) { :released }

      context 'new release' do
        context 'released >= 2 weeks ago' do
          let(:released_on) { 2.weeks.ago.to_date }
          let(:aired_on) { '' }

          it 'generates 2 released news topics for both locales' do
            expect(anime.released_news_topics).to have(2).items
          end
        end

        context 'released_on is nil but aired >= 15 months ago' do
          let(:released_on) { '' }
          let(:aired_on) { 15.months.ago.to_date }

          it 'generates 2 released news topics for both locales' do
            expect(anime.released_news_topics).to have(2).items
          end
        end
      end

      context 'old release' do
        context 'released < 2 weeks ago' do
          let(:released_on) { 2.weeks.ago.to_date - 1.day }
          let(:aired_on) { '' }

          it 'does not generate released news topics' do
            expect(anime.released_news_topics).to be_empty
          end
        end

        context 'released_on is nil and aired_on < 15 months ago' do
          let(:released_on) { '' }
          let(:aired_on) { 15.months.ago.to_date - 1.day }

          it 'does not generate released news topics' do
            expect(anime.released_news_topics).to be_empty
          end
        end

        context 'released_on and aired_on are both nil' do
          let(:released_on) { '' }
          let(:aired_on) { '' }

          it 'does not generate released news topics' do
            expect(anime.released_news_topics).to be_empty
          end
        end
      end
    end
  end
end
