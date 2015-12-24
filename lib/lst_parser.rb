class LstParser
  def parse text
    text.strip.split(/[\n\r]+---[\n\r]+/).map {|v| parse_group v }
  end

private

  def parse_group group
    group.strip.split(/[\r\n]+/).map { |v| v.sub(/ #.*/, '').strip }
  end
end
