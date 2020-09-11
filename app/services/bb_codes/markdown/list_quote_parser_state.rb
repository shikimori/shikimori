class BbCodes::Markdown::ListQuoteParserState # rubocop:disable ClassLength
  LIST_ITEM_VARIANTS = ['- ', '+ ', '* ']
  BLOCKQUOTE_VARIANT_1 = '> '
  BLOCKQUOTE_VARIANT_2 = '&gt; '

  UL_OPEN = BbCodes::Tags::ListTag::UL_OPEN
  UL_CLOSE = BbCodes::Tags::ListTag::UL_CLOSE

  BLOCKQUOTE_OPEN = "<blockquote class='b-quote-v2'>"
  BLOCKQUOTE_CLOSE = '</blockquote>'

  MULTILINE_BBCODES_MAX_SIZE = MULTILINE_BBCODES.map(&:size).max

  TAG_CLOSE_REGEXP = %r{</\w+>}

  def initialize text, index = 0, nested_sequence = ''
    @text = text
    @nested_sequence = nested_sequence
    @index = index

    @state = []
  end

  def to_html
    # binding.pry
    # ap @text
    parse_line while @index < @text.size

    @state.join('')
  end

private

  def parse_line skippable_sequence = '' # rubocop:disable all
    if skippable_sequence?(skippable_sequence.presence || @nested_sequence)
      move((skippable_sequence.presence || @nested_sequence).size)
    end

    start_index = @index

    while @index <= @text.size
      is_start = start_index == @index
      is_end = @text[@index] == "\n" || @text[@index].nil?

      if is_end
        finalize_content start_index, @index - 1
        move 1
        return
      end

      if is_start
        seq_2 = @text[@index..(@index + 1)]
        return parse_list seq_2 if seq_2.in? LIST_ITEM_VARIANTS
        return parse_blockquote seq_2 if seq_2 == BLOCKQUOTE_VARIANT_1

        seq_5 = @text[@index..(@index + 4)]
        return parse_blockquote seq_5 if seq_5 == BLOCKQUOTE_VARIANT_2
      end

      if @text[@index] == '['
        sequence = @text.slice(@index + 1, MULTILINE_BBCODES_MAX_SIZE)
        tag = MULTILINE_BBCODES.find { |bbcode| sequence.starts_with? bbcode }

        # traverse through nested possibly multiline bbcode
        next if tag && traverse(tag)
      end

      move 1
    end

    finalize_content start_index, @index
  end

  def traverse tag
    rest_text = @text[@index..]
    tag_end = "[/#{tag}]"
    tag_end_index = rest_text.index tag_end

    if tag_end_index
      move tag_end_index + tag_end.length
      true
    else
      false
    end
  end

  def parse_list tag_sequence
    prior_sequence = @nested_sequence

    @state.push UL_OPEN
    @nested_sequence += tag_sequence
    # puts "processBulletList '#{@nested_sequence}'"

    loop do
      move tag_sequence.length
      @state.push '<li>'
      parse_list_lines prior_sequence, '  '
      @state.push '</li>'

      break unless sequence_continued?
    end

    @state.push UL_CLOSE

    @nested_sequence = @nested_sequence.slice(0, @nested_sequence.size - tag_sequence.size)
    # puts "processBulletList '#{@nested_sequence}'"
  end

  def parse_list_lines prior_sequence, tag_sequence
    nested_sequence_backup = @nested_sequence

    @nested_sequence = prior_sequence + tag_sequence
    # puts "processBulletListLines '#{@nested_sequence}'"
    line = 0

    loop do
      if line.positive?
        @state.push "\n"
        move @nested_sequence.length
      end

      parse_line
      line += 1
      break unless sequence_continued?
    end

    @nested_sequence = nested_sequence_backup
    # puts "processBulletListLines '#{@nested_sequence}'"
  end

  def parse_blockquote tag_sequence
    is_first_line = true
    @state.push BLOCKQUOTE_OPEN
    @nested_sequence += tag_sequence
    # puts "processBlockQuote '#{@nested_sequence}'"

    loop do
      @state.push "\n" unless is_first_line || @state.last.match?(TAG_CLOSE_REGEXP)

      parse_line is_first_line ? tag_sequence : ''
      is_first_line = false
      break unless sequence_continued?
    end

    @state.push BLOCKQUOTE_CLOSE
    @nested_sequence = @nested_sequence.slice(0, @nested_sequence.size - tag_sequence.size)
    # puts "processBlockQuote '#{@nested_sequence}'"
  end

  def move steps
    @index += steps
  end

  def finalize_content start_index, end_index
    @state.push @text[start_index..end_index]
  end

  def sequence_continued?
    @text.slice(@index, @nested_sequence.size) == @nested_sequence
  end

  def skippable_sequence? skip_sequence
    skip_sequence.present? &&
      @text.slice(@index, skip_sequence.size) == skip_sequence
  end

# export function extractUntil(
#   text,
#   sequence,
#   startIndex,
#   maxIndex = startIndex + 1000,
#   isIgnoreNewLine = false
# ) {
#   for (let i = startIndex; i <= (maxIndex || text.length); i++) {
#     const char = text[i];
#     const isEnd = isIgnoreNewLine ?
#       (char === undefined) :
#       (char === '\n' || char === undefined);
# 
#     if (char === sequence[0] && (
#       sequence.length === 1 || text.slice(i, i + sequence.length) === sequence
#     )) {
#       return text.slice(startIndex, i);
#     }
#     if (isEnd) { return null; }
#   }
#   return null;
# }

end
