class Anidb::SanitizeText < Mal::SanitizeText
  SOURCE_REGEXP = %r{
    \n*
    <i>
    Source:\s(?<source>.+?)
    </i>
    \n*
  }mix

  private

  def bb_source text
    super.gsub(SOURCE_REGEXP, '[source]\k<source>[/source]')
  end
end
