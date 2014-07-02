class DanbooruTag < ActiveRecord::Base
  Copyright = 3
  Character = 4

  # поиск среди списка names какого-либо имени, входящего в набор тегов tags
  def self.match(names, tags, no_correct)
    names.compact.each do |name|
      tag = name.gsub(/'/, '').gsub(/ /, '_').downcase
      while !tags.include?(tag)
        break if no_correct
        if tag.include?('-')
          tag = tag.sub('-', '_')
          next
        end
        if tag.include?('!')
          tag = tag.sub('!', '')
          next
        end
        separator = tag.rindex /[_:(]/
        if separator && separator > 6
          tag = tag[0, separator]
          next
        end
        break
      end

      return tag if tags.include?(tag)
    end
    nil
  end
end
