class PersonMalParser < CharacterMalParser
  # загрузка информации о человеке
  def fetch_entry_data id
    content = get entry_url(id)

    entry = {}

    doc = Nokogiri::HTML(content)
    entry[:name] = cleanup(doc.css("h1").text.gsub("  ", " ")).gsub(/^(.*), (.*)$/, '\2 \1')
    entry[:img] = doc.css("td.borderClass > div > img").first.attr(:src)
    entry[:given_name] = parse_line("Given name", content, false)
    entry[:given_name] = nil if entry[:given_name] == ''
    entry[:family_name] = parse_line("Family name", content, false)
    entry[:family_name] = nil if entry[:family_name ] == ''
    entry[:japanese] = "#{entry[:family_name]} #{entry[:given_name]}" if entry[:given_name] && entry[:family_name]
    entry[:birthday] = parse_date(parse_line("Birthday", content, false))
    entry[:website] = parse_line("Website", content, false)
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
