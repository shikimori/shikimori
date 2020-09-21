# NOTE: the class is not used anymore. delete it later
class BbCodes::Tags::CleanupNewLines
  method_object :text, :tags

  TAGS = %i[div quote]
  TAG_REGEXP = {
    div: {
      start: BbCodes::Tags::DivTag::TAG_START_REGEXP.source,
      end: BbCodes::Tags::DivTag::TAG_END_REGEXP.source
    },
    quote: {
      start: / \[ quote (?: =[^\]]+ )? \] /mix.source,
      end: %r{ \[ /quote \] }mix.source
    }
  }
  CLEANUP_MARKER = 'øØøØøØø'
  CLEANUP_REGEXP = %i[div quote].each_with_object({}) do |tag, memo|
    memo[tag] = {}

    # memo[tag][:tag_start_1] = /
    #   (?<! #{CLEANUP_MARKER} )
    #   \n
    #   (?<tag>#{TAG_REGEXP[tag][:start]})
    # /mix
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

  def call
    Array(@tags)
      .inject(@text) { |text, tag| cleanup text, tag }
      .gsub(CLEANUP_MARKER, '')
  end

  def cleanup text, tag
      # .gsub CLEANUP_REGEXP[tag][:tag_start_1] do
      #   CLEANUP_MARKER + $LAST_MATCH_INFO[:tag]
      # end
    text
      .gsub CLEANUP_REGEXP[tag][:tag_start_2] do
        $LAST_MATCH_INFO[:tag] + CLEANUP_MARKER
      end
      .gsub CLEANUP_REGEXP[tag][:tag_end_1] do
        CLEANUP_MARKER + $LAST_MATCH_INFO[:tag]
      end
      .gsub CLEANUP_REGEXP[tag][:tag_end_2] do
        $LAST_MATCH_INFO[:tag] + CLEANUP_MARKER
      end
  end
end
