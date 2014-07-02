class DanbooruImporter
  def import pages
    1.upto(pages) {|page| import_page page, 1000 }
  end

private
  def import_page page, limit
    content = get_page page, limit
    found_tags = JSON.parse(content)

    existing_tags = Set.new DanbooruTag.pluck :id
    new_tags = found_tags.select {|v| !existing_tags.include?(v['id']) }

    new_tags.each_slice(5000) do |tags|
      batch = []
      tags.each do |tag|
        batch << DanbooruTag.new(name: tag['name'], kind: tag['type'], ambiguous: tag['ambiguous']) do |v|
          v.id = tag['id']
        end
      end
      DanbooruTag.import batch
      puts "imported batch of #{batch.size} tags" unless Rails.env == 'test'
    end
  end

  def get_page page, limit
    url = "http://danbooru.donmai.us/tag/index.json?&limit=#{limit}&order=created_at&page=#{page}"
    Proxy.get url, timeout: 30, required_text: '"type"', no_proxy: true
  end
end
