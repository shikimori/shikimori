class BbCodes::CleanupNewLines
  method_object :text, :tag

  CLEANUP_MARKER = 'øØøØøØø'
  TAG_REGEXP = {
    div: {
      start: / \[ div (?: =[^\]]+ )? \] /mix.source,
      end: %r{ \[ /div \] }mix.source
    },
    quote: {
      start: / \[ quote (?: =[^\]]+ )? \] /mix.source,
      end: %r{ \[ /quote \] }mix.source
    }
  }
  CLEANUP_REGEXP = %i[div quote].each_with_object({}) do |tag, memo|
    memo[tag] = {}

    memo[tag][:tag_start_1] = /
      (?<! #{CLEANUP_MARKER} )
      \n
      (?<tag>#{TAG_REGEXP[tag][:start]})
    /mix
    memo[tag][:tag_start_2] = /
      (?<tag>#{TAG_REGEXP[tag][:start]})
      \n
      (?! #{CLEANUP_MARKER} )
    /mix
    memo[tag][:tag_end_1] = /
      (?<! #{CLEANUP_MARKER} )
      \n
      (?<tag>#{TAG_REGEXP[tag][:end]})
    /mix
    memo[tag][:tag_end_2] = /
      (?<tag>#{TAG_REGEXP[tag][:end]})
      \n
      (?! #{CLEANUP_MARKER} )
    /mix
  end

  # rubocop:disable MethodLength
  # rubocop:disable AbcSize
  def call
    @text
      .gsub CLEANUP_REGEXP[@tag][:tag_start_1] do
        CLEANUP_MARKER + $LAST_MATCH_INFO[:tag]
      end
      .gsub CLEANUP_REGEXP[@tag][:tag_start_2] do
        $LAST_MATCH_INFO[:tag] + CLEANUP_MARKER
      end
      .gsub CLEANUP_REGEXP[@tag][:tag_end_1] do
        CLEANUP_MARKER + $LAST_MATCH_INFO[:tag]
      end
      .gsub CLEANUP_REGEXP[@tag][:tag_end_2] do
        $LAST_MATCH_INFO[:tag] + CLEANUP_MARKER
      end
      .gsub(CLEANUP_MARKER, '')
  end
  # rubocop:enablk MethodLength
  # rubocop:enable AbcSize
end
