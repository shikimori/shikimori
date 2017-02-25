class BbCodes::DbEntryUrlTag
  include Singleton

  REGEXP = %r{
    #{BbCodes::UrlTag::BEFORE_URL.source}
    (?<url>
      (?: https?: )?
      //shikimori.\w+
      /(?<type> animes|mangas|characters|people )
      /[A-u]* (?<id>\d+) (?<other> [^\s<\[\].,;:)(]* )
    )
  }mix

  TYPES = {
    'animes' => 'anime',
    'mangas' => 'manga',
    'characters' => 'character',
    'people' => 'person'
  }

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
