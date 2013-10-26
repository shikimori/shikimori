class DanbooruTag < ActiveRecord::Base
  Copyright = 3
  Character = 4

  # импорт новых тегов с Danbooru
  def self.import_from_danbooru(pages)
    # 196 characters
    [Character, Copyright].each do |type|
      1.upto(pages) do |page|
        import_type(type, 1000, page)
      end
    end
  end

  # поиск среди списка names какого-либо имени, входящего в набор тегов tags
  def self.match(names, tags, no_correct)
    names.compact.each do |name|
      tag = name.gsub(/'/, '').gsub(/ /, '_').downcase
      while !tags.include?(tag)
        break if no_correct
        if tag.include?('-')
          tag = tag.sub('-', '_')
          next
        end
        if tag.include?('!')
          tag = tag.sub('!', '')
          next
        end
        separator = tag.rindex /[_:(]/
        if separator && separator > 6
          tag = tag[0, separator]
          next
        end
        break
      end

      return tag if tags.include?(tag)
    end
    nil
  end

private
  def self.import_type(type, limit, page)
    url = "http://danbooru.donmai.us/tag/index.json?type=#{type}&limit=#{limit}&order=created_at&page=#{page}"

    content = Proxy.get(url, timeout: 30, required_text: '"type"', no_proxy: true)

    found_tags = JSON.parse(content)

    existing_tags = Set.new DanbooruTag.where(kind: type).pluck :id
    new_tags = found_tags.select {|v| !existing_tags.include?(v['id']) }

    new_tags.each_slice(5000) do |tags|
      batch = []
      tags.each do |tag|
        batch << DanbooruTag.new(name: tag['name'], kind: tag['type'], ambiguous: tag['ambiguous']) {|v| v.id = tag['id']}
      end
      DanbooruTag.import batch
      puts "imported batch of #{batch.size} tags" unless Rails.env == 'test'
    end
  end
end
