class ResetElasticIndexesV2 < ActiveRecord::Migration[5.1]
  def change
    unless Rails.env.test?
      AnimesIndex.reset!
      MangasIndex.reset!
      RanobeIndex.reset!
      PeopleIndex.reset!
      CharactersIndex.reset!
      ClubsIndex.reset!
      CollectionsIndex.reset!
      UsersIndex.reset!
      TopicsIndex.reset!
    end
  end
end
