# frozen_string_literal: true

describe Animes::TrackStatusChanges do
  let!(:news_topic) { nil }
  before { anime.assign_attributes status: new_status }
  subject! { described_class.call anime }

  context 'status not changed' do
    let(:anime) { create :anime, status: old_status }

    let(:old_status) { :anons }
    let(:new_status) { :anons }

    it { expect(anime.status_change).to eq nil }
  end

  describe 'rollback ongoing status' do
    let(:anime) { create :anime, status: old_status, aired_on: aired_on }

    let(:old_status) { :anons }
    let(:new_status) { :ongoing }

    context 'without aired_on' do
      let(:aired_on) { nil }
      it 'does not rollback ongoing status' do
        expect(anime).to be_ongoing
      end
    end

    context 'aired_on not in the future' do
      let(:aired_on) { Time.zone.today }
      it 'does not rollback ongoing status' do
        expect(anime).to be_ongoing
      end
    end

    context 'aired_on in the future' do
      let(:aired_on) { Time.zone.tomorrow }
      it 'rollbacks ongoing status' do
        expect(anime).to be_anons
      end
    end
  end

  describe 'rollback released status' do
    let(:anime) do
      create :anime,
        status: old_status,
        released_on: released_on,
        episodes: episodes,
        episodes_aired: episodes_aired
    end

    let(:old_status) { :ongoing }
    let(:new_status) { :released }
    let(:episodes) { 0 }
    let(:episodes_aired) { 0 }

    context 'without released_on' do
      let(:released_on) { nil }

      it 'does not rollback released status' do
        expect(anime).to be_released
        expect(anime.released_on).to eq released_on
      end
    end

    context 'released_on in the past' do
      let(:released_on) { Time.zone.yesterday }
      let(:episodes) { [0, 10].sample }

      it 'does not rollback released status', :focus do
        expect(anime).to be_released
        expect(anime.released_on).to eq released_on
      end
    end

    context 'released_on in the future' do
      let(:released_on) { Time.zone.tomorrow }

      it 'does rollback release status' do
        expect(anime).to be_ongoing
        expect(anime.released_on).to eq released_on
      end

      context 'all episodes aired' do
        let(:episodes) { 10 }
        let(:episodes_aired) { 10 }

        it 'does not rollback released status' do
          expect(anime).to be_released
          expect(anime.released_on).to eq released_on
        end
      end
    end
  end

  describe 'rollback released status' do
    let(:anime) { create :anime, status: old_status }
    let!(:news_topic) do
      create :news_topic, linked: anime, action: AnimeHistoryAction::Released
    end
    let(:old_status) { :released }
    let(:new_status) { :ongoing }

    it 'deletes released news topic' do
      expect(anime).to be_ongoing
      expect { news_topic.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
