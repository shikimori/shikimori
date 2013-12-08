require 'spec_helper'

class AniMangaListImporter::ImporterTest
  include AniMangaListImporter
end

describe AniMangaListImporter do
  let(:anime1) { create :anime, name: "Zombie-Loan", episodes: 22 }
  let(:anime2) { create :anime, name: "Zombie-Loan Specials" }

  let (:user) { FactoryGirl.create :user }
  let (:list) do
    [{
      status: UserRateStatus.get(UserRateStatus::Watching),
      score: 5,
      id: anime1.id,
      episodes: 1
    }, {
      status: UserRateStatus.get(UserRateStatus::Completed),
      score: 8,
      id: anime2.id,
      episodes: 20
    }]
  end
  let (:importer) { AniMangaListImporter::ImporterTest.new }

  it 'simple import' do
    expect {
      added, updated, not_imported = importer.import(user, Anime, list, false)

      added.should have(2).items
      updated.should be_empty
      not_imported.should be_empty
    }.to change(UserRate, :count).by(2)
  end

  it 'import with broken episodes num' do
    list[0][:episodes] = anime1.episodes + 1
    expect {
      importer.import(user, Anime, [list[0]], false)
    }.to change(UserRate, :count).by(1)
  end

  it 'import with replace' do
    importer.import(user, Anime, [list[0]], false)
    expect {
      added, updated, not_imported = importer.import(user, Anime, list, true)

      added.should have(1).item
      updated.should have(1).item
      not_imported.should be_empty
    }.to change(UserRate, :count).by(1)
  end

  it 'import w/o replace' do
    importer.import(user, Anime, [list[0]], false)
    expect {
      added, updated, not_imported = importer.import(user, Anime, list, false)

      added.should have(1).item
      updated.should be_empty
      not_imported.should have(0).item
    }.to change(UserRate, :count).by(1)
  end
end
