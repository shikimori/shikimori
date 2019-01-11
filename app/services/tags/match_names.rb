class Tags::MatchNames
  method_object %i[names! tags! no_correct!]

  SHORT_NAME_SIZE = 6

  def call
    @names.each do |name|
      tag = name.delete("'").tr(' ', '_').downcase

      until @tags.include?(tag)
        break if @no_correct

        if tag.include?('-')
          tag = tag.sub('-', '_')
          next
        end
        if tag.include?('!')
          tag = tag.sub('!', '')
          next
        end

        separator = tag.rindex(/[_:(]/)
        if separator && separator > SHORT_NAME_SIZE
          tag = tag[0, separator]
          next
        end
        break
      end

      return tag if @tags.include?(tag)
    end

    nil
  end
end
