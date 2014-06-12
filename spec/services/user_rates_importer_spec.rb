require 'spec_helper'

describe UserRatesImporter do
  let(:anime_1) { create :anime, name: "Zombie-Loan", episodes: 22 }
  let(:anime_2) { create :anime, name: "Zombie-Loan Specials" }

  let(:anime_1_id) { anime_1.id }
  let(:anime_1_status) { UserRate.statuses[:watching] }
  let(:user) { create :user }
  let(:list) do
    [{
      status: anime_1_status,
      score: 5,
      id: anime_1_id,
      episodes: 1,
      rewatches: 2,
      volumes: 7,
      chapters: 8,
      text: 'test'
    }, {
      status: UserRate.statuses[:completed],
      score: 8,
      id: anime_2.id,
      episodes: 20
    }]
  end
  let(:importer) { UserRatesImporter.new user, Anime }
  let(:with_replace) { false }

  subject { importer.import list, with_replace }

  let(:added) { subject[0] }
  let(:updated) { subject[1] }
  let(:not_imported) { subject[2] }

  context 'new records' do
    before { subject }

    context 'everything is matched' do
      it 'properly imported'do
        expect(added).to have(2).items
        expect(updated).to be_empty
        expect(not_imported).to be_empty

        rates = user.reload.anime_rates.to_a
        expect(rates).to have(2).items
        expect(rates.first.target_id).to eq anime_1_id
        expect(rates.first).to be_watching
        expect(rates.first.rewatches).to eq 2
        expect(rates.first.score).to eq 5
        expect(rates.first.episodes).to eq 1
        expect(rates.first.volumes).to eq 7
        expect(rates.first.chapters).to eq 8
        expect(rates.first.text).to eq 'test'
      end
    end

    context 'nil id is not matched' do
      let(:anime_1_id) { nil }

      it 'properly imported'do
        expect(added).to have(1).item
        expect(updated).to be_empty
        expect(not_imported).to have(1).item

        expect(user.reload.anime_rates).to have(1).item
      end
    end

    context 'nil status is not matched' do
      let(:anime_1_status) { nil }

      it 'properly imported'do
        expect(added).to have(1).item
        expect(updated).to be_empty
        expect(not_imported).to have(1).item

        expect(user.reload.anime_rates).to have(1).item
      end
    end
  end

  context 'existing records' do
    let!(:user_rate) { create :user_rate, user: user, anime: anime_1 }
    before { subject }

    describe 'replace' do
      let(:with_replace) { true }

      it 'properly imported'do
        expect(added).to have(1).item
        expect(updated).to have(1).item
        expect(not_imported).to be_empty
        expect(user.reload.anime_rates).to have(2).items
      end
    end

    describe 'w/o replace' do
      let(:with_replace) { false }

      it 'properly imported'do
        expect(added).to have(1).item
        expect(updated).to be_empty
        expect(not_imported).to be_empty
        expect(user.reload.anime_rates).to have(2).items
      end
    end
  end
end
