class MigrateBlobDataIntoBigDataCache < ActiveRecord::Migration[5.1]
  def change
    # BlobData.find_each do |blob_data|
    #   value = BlobData.get(blob_data.key)
    #   next if value.blank?

    #   BigDataCache.write blob_data.key, value
    # end
  end
end
