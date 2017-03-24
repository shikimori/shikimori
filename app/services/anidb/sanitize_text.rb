class Anidb::SanitizeText < Mal::SanitizeText
  ANIDB_SOURCE_REGEXP = %r{
    \n*
    <i>
    Source:\s(?<source>.+?)
    </i>
    \n*
  }mix

  ANIDB_CHARACTER_LINK_REGEXP = %r{
    <a [^>]*? href="(?<url>https://anidb.net/ch[^"]+)" [^>]*? >
      (?<name>[^<]*)
    </a>
  }mix

  ANIDB_CREATOR_LINK_REGEXP = %r{
    <a [^>]*? href="(?<url>https://anidb.net/cr[^"]+)" [^>]*? >
      (?<name>[^<]*)
    </a>
  }mix

  private

  def bb_source text
    super.gsub(ANIDB_SOURCE_REGEXP, '[source]\k<source>[/source]')
  end

  def bb_link text
    text
      .gsub(ANIDB_CHARACTER_LINK_REGEXP, '[\k<name>]')
      .gsub(ANIDB_CREATOR_LINK_REGEXP, '[\k<name>]')
      .gsub(LINK_REGEXP, '\k<name>')
  end
end
