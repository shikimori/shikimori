require 'spec_helper'

describe UserRatesImporter do
  let(:anime_1) { create :anime, name: "Zombie-Loan", episodes: 22 }
  let(:anime_2) { create :anime, name: "Zombie-Loan Specials" }

  let(:user) { create :user }
  let(:list) do
    [{
      status: UserRate.statuses[:watching],
      score: 5,
      id: anime_1.id,
      episodes: 1
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

    it { expect(added).to have(2).items }
    it { expect(updated).to be_empty }
    it { expect(not_imported).to be_empty }

    it { expect(user.reload.anime_rates).to have(2).items }
  end

  context 'existing records' do
    let!(:user_rate) { create :user_rate, user: user, anime: anime_1 }
    before { subject }

    describe 'replace' do
      let(:with_replace) { true }

      it { expect(added).to have(1).item }
      it { expect(updated).to have(1).item }
      it { expect(not_imported).to be_empty }
      it { expect(user.reload.anime_rates).to have(2).items }
    end

    describe 'w/o replace' do
      let(:with_replace) { false }

      it { expect(added).to have(1).item }
      it { expect(updated).to be_empty }
      it { expect(not_imported).to be_empty }
      it { expect(user.reload.anime_rates).to have(2).items }
    end
  end
end
