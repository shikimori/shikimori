class BbCodes::Markdown::ListParserState
  def initialize text, index = 0, nested_sequence = ''
    @text = text
    @nested_sequence = nested_sequence
    @index = index

    @skippable_sequence = ''
    @out = "<ul class='b-list'>"
  end

  def to_html
    parse_line while @index < @text.size

    @out + '</ul>'
  end

private

  def parse_line skippable_sequence = ''
    if skippable_sequence?(skippable_sequence || @nested_sequence)
      move((skippable_sequence || @nested_sequence).size)
    end

    start_index = @index

    while @index <= @text.size
      is_start = start_index == @index
      is_end = char1 == "\n" || char1.nil?
      #
      # if (is_end) {
      #   this.finalizeParagraph()
      #   move()
      #   return
      # }
      #
      # if (is_start) {
      #     case '- ':
      #     case '+ ':
      #     case '* ':
      #       processBulletList(this, seq2)
      #       break outer
      #
      #     case '# ':
      #       processHeading(this, seq2, 1)
      #       break outer
      #   }
      #
      # }

      @out += @char1
      move
    end
  end

  def skippable_sequence? skip_sequence
    skip_sequence.present? &&
      @text[@index] == skip_sequence[0] &&
      @text[@index..(@index + skip_sequence.size)] == skip_sequence
  end

  def move steps = 1 # , isSkipNewLine = false
    @index += steps
    @char1 = @text[@index]

    # if isSkipNewLine && (@char1 == '\n' || @char1.nil?)
    #   move
    # end
  end
end
