class CleanupBtjunkie < ActiveRecord::Migration
  def self.up
    BlobData.where(:value.like => '%btjunkie%').each do |torrent|
      torrent.value = torrent.value.select { |v| v[:link] !~ /btjunkie/ }
      torrent.save
    end
    BlobData.where(:value => "--- []\n").delete_all
  end
end
