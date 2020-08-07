class BbCodes::Markdown::ListQuoteParserState
  ITEM_VARIANTS = ['- ', '+ ', '* ']

  UL_OPEN = BbCodes::Tags::ListTag::UL_OPEN
  UL_CLOSE = BbCodes::Tags::ListTag::UL_CLOSE

  def initialize text, index = 0, nested_sequence = ''
    @text = text
    @nested_sequence = nested_sequence
    @index = index

    @state = []
  end

  def call
    parse_line while @index < @text.size

    @state.join('')
  end

private

  def parse_line # rubocop:disable MethodLength
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

        if ITEM_VARIANTS.include? seq_2
          parse_list seq_2
          return
        end
      end

      move 1
    end

    finalize_content start_index, @index
  end

  def sequence_continued?
    @text[@index..(@index + @nested_sequence.size - 1)] == @nested_sequence
  end

  def parse_list tag_sequence
    prior_sequence = @nested_sequence

    @state.push UL_OPEN
    @nested_sequence += tag_sequence

    loop do
      move tag_sequence.length
      @state.push '<li>'
      parse_list_lines prior_sequence, '  '
      @state.push '</li>'

      break unless sequence_continued?
    end

    @state.push UL_CLOSE

    @nested_sequence = @nested_sequence[0..(@nested_sequence.size - tag_sequence.size)]
  end

  def parse_list_lines prior_sequence, tag_sequence
    nested_sequence_backup = @nested_sequence

    @nested_sequence = prior_sequence + tag_sequence
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
  end

  def move steps
    @index += steps
  end

  def finalize_content start_index, end_index
    @state.push @text[start_index..end_index]
  end
end
