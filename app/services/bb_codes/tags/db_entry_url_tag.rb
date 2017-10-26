class BbCodes::Tags::DbEntryUrlTag
  include Singleton

  TYPES = {
    'animes' => 'anime',
    'mangas' => 'manga',
    'ranobe' => 'ranobe',
    'characters' => 'character',
    'people' => 'person'
  }

  REGEXP = %r{
    #{BbCodes::Tags::UrlTag::BEFORE_URL.source}
    (?<url>
      (?: https?: )?
      //shikimori.\w+
      /(?<type> #{TYPES.keys.join '|'} )
      /[A-u]* (?<id>\d+) (?<other> [^\s<\[\].,;:)(]* )
    )
  }mix

  def format text
    text.gsub REGEXP do |match|
      type = TYPES[$LAST_MATCH_INFO[:type]]
      id = $LAST_MATCH_INFO[:id]
      other = $LAST_MATCH_INFO[:other]

      if type && (other.blank? || !other.include?('/'))
        "[#{type}=#{id} fallback=#{match}]"
      else
        match
      end
    end
  end
end
