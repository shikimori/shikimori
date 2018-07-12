class MigrateBlobDataIntoBigDataCache < ActiveRecord::Migration[5.1]
  def up
    return unless defined? BlobData
    return unless defined? BigDataCache

    BlobData.where("key like '%torrents_%'").delete_all
    BlobData.where("key like '%subtitles%'").delete_all

    BlobData.find_each do |blob_data|
      value = BlobData.get(blob_data.key)
      next if value.blank?

      BigDataCache.write blob_data.key, cleanup(value)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration # because BlobData model is deleted
  end

  def cleanup value
    if value.is_a? Array
      value.each_with_index do |sub_value, index|
        value[index] = cleanup sub_value
      end

    elsif value.is_a? Hash
      value.symbolize_keys.each do |key, sub_value|
        value[key] = cleanup sub_value
      end

    elsif value.is_a? String
      new_value = value.force_encoding('utf-8')

      if new_value.valid_encoding?
        new_value
      else
        new_value.encode(
          'utf-8',
          'us-ascii',
          undef: :replace,
          invalid: :replace,
          replace: ''
        )
      end
    else
      value
    end
  end
end
