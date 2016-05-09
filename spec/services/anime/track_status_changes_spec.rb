# frozen_string_literal: true

describe Anime::TrackStatusChanges do
  let(:anime) { create :anime, status: old_status }

  before do
    anime.assign_attributes status: new_status
    Anime::TrackStatusChanges.call anime
  end

  context 'status not changed' do
    let(:old_status) { :anons }
    let(:new_status) { :anons }
    it { expect(anime.status).to eq new_status }
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
    let(:anime) { create :anime, status: old_status, released_on: released_on }

    let(:old_status) { :ongoing }
    let(:new_status) { :released }

    context 'without released_on' do
      let(:released_on) { nil }
      it 'does not rollback released status' do
        expect(anime).to be_released
        expect(anime.released_on).to eq released_on
      end
    end

    context 'released_on in the past' do
      let(:released_on) { Time.zone.yesterday }
      it 'does not rollback released status' do
        expect(anime).to be_released
        expect(anime.released_on).to eq released_on
      end
    end

    context 'released_on not in the past' do
      let(:released_on) { Time.zone.today }
      it 'rollbacks released status' do
        expect(anime).to be_ongoing
        expect(anime.released_on).to eq nil
      end
    end
  end
end
