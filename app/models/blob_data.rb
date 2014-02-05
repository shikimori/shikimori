class BlobData < ActiveRecord::Base
  self.table_name = 'blob_datas'
  serialize :value

  before_save :check_value_size

  def self.get(key)
    data = BlobData.find_by_key(key)

    # временный костыль после перехода на 1.9.3
    data.value.each do |v|
      if v.kind_of?(Hash) && v[:title]
        #v[:title] = v[:title].encode('utf-8', :undef => :replace, :invalid => :replace, :replace => '') if v[:title].encoding.name != 'UTF-8'
        v[:title] = v[:title].force_encoding('utf-8')# if !v[:title].valid_encoding?
        v[:title] = v[:title].encode('utf-8', 'us-ascii', :undef => :replace, :invalid => :replace, :replace => '') if !v[:title].valid_encoding?
      end
    end if data && data.value.kind_of?(Array)

    data.value.each do |k,v|
      if v.kind_of?(Hash) && v[:title]
        #v[:title] = v[:title].encode('utf-8', :undef => :replace, :invalid => :replace, :replace => '') if v[:title].encoding.name != 'UTF-8'
        v[:title] = v[:title].force_encoding('utf-8')# if !v[:title].valid_encoding?
        v[:title] = v[:title].encode('utf-8', 'us-ascii', :undef => :replace, :invalid => :replace, :replace => '') if !v[:title].valid_encoding?
      end
    end if data && data.value.kind_of?(Hash)

    data ? data.value : nil
  end

  def self.set(key, value)
    # временный костыль после перехода на 1.9.3
    value.each do |v|
      if v.kind_of?(Hash) && v[:title] && !v[:title].valid_encoding?
        v[:title] = v[:title].encode('utf-8', 'us-ascii', :undef => :replace, :invalid => :replace, :replace => '')
      end
    end if value.kind_of?(Array)

    if value == []
      data = BlobData.find_by_key(key)
      data.destroy if data
    else
      data = BlobData.find_or_create_by_key(key)
      data.value = value
      data.save
    end
  end

  def check_value_size
    while Marshal.dump(value).size > 45000
      if value.respond_to?(:keys)
        key = if value[value.keys.first].kind_of?(Hash) && value[value.keys.first][:feed]
          value.sort_by {|k,v| -v[:feed].size }.first.first # удаляем по самому крупному ключу
        else
          value.keys.first
        end

        value.delete(key)
      else
        value.shift
      end
    end
  end
end
