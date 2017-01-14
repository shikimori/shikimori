class PersonMalParser < CharacterMalParser
  # загрузка информации о человеке
  def fetch_model id
    content = get entry_url(id)

    entry = {}

    doc = Nokogiri::HTML content
    entry[:name] = cleanup(doc.css('h1').text.gsub('  ', ' ')).gsub(/^(.*), (.*)$/, '\2 \1')
    entry[:img] = parse_poster doc
    given_name = parse_line 'Given name', content, false
    family_name = parse_line 'Family name', content, false
    if given_name.present? && family_name.present?
      entry[:japanese] = "#{family_name} #{given_name}"
    end
    entry[:birthday] = parse_date parse_line('Birthday', content, false)
    entry[:website] = parse_line 'Website', content, false

    if entry[:website]
      if entry[:website] =~ /href=\"(.*?)\"/
        entry[:website] = $1
      else
        entry[:website].gsub!(/<[^>]+>/, '')
      end
    end

    entry
  end

private

  def entry_url id
    "http://myanimelist.net/people/#{id}"
  end
end
