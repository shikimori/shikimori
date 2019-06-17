class GenerateCopyrightedIds < ServiceObjectBase
  URL_TEMPLATE = 'https://lumendatabase.org/notices/search?'\
    'utf8=%E2%9C%93&term=shikimori.one&sort_by=&page='

  VALID_PATH = %r{/(animes|mangas|ranobe|characters|people)/\w+(?=-)}
  FAIL_TEXT = 'Search Temporarily Unavailable'

  CONFIG_FILE = "#{::Rails.root}/config/app/copyrighted_ids.yml"

  def call
    hash = copyrighted_entries
    File.open(CONFIG_FILE, 'w') { |f| YAML.dump hash, f }
    hash
  end

  def copyrighted_entries
    all_links.each_with_object({}) do |url, memo|
      path = URI(url).path
      next unless path.match? VALID_PATH

      parts = path.split('/')

      type = parts[1].singularize.to_sym
      id = parts[2].gsub(/-.*/, '')

      (memo[type] ||= []).push id
      (memo[:ranobe] ||= []).push id if type == :manga
    end
  end

  def all_links
    1.upto(total_pages).flat_map do |page|
      page_links(page)
    end
  end

  def page_links page
    page_doc(page).css('li.excerpt').text.strip
      .split("\n")
      .map(&:strip)
      .select(&:present?)
  end

  def total_pages
    page_doc(1).css('.last a')[0].attr('href').match(/page=(\d+)/)[1].to_i
  end

private

  def page_doc page
    Nokogiri::HTML get_page(URL_TEMPLATE + page.to_s)
  end

  def get_page url
    Rails.cache.fetch(url, expires_in: 1.week) do
      response = Faraday.get(url) do |req|
        req.options[:timeout] = 300
        req.options[:open_timeout] = 300
      end

      if response.body && !response.body.include?(FAIL_TEXT)
        sleep 1 unless Rails.env.test?
        response.body
      else
        raise 'search unavailable'
      end
    end
  end
end
