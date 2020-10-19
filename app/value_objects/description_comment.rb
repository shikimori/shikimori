# комментарий с description описанием вместо обычного body
# использутеся для превью текстов описаний
class DescriptionComment < SimpleDelegator
  def initialize comment, target_type, target_id, lang
    super comment
    @target = target_type.constantize.find(target_id)
    @lang = lang
  end

  def html_body
    if @lang == 'ru'
      # TODO: move gsub into BbCodes::EntryText
      BbCodes::EntryText
        .call(body, @target)
        .gsub(%r{<span class="name-ru">(.*?)</span>}, '\1')
        .gsub(%r{<span class="name-en">.*?</span>}, '')
        .html_safe
    else
      # TODO: move gsub into BbCodes::EntryText
      BbCodes::Text
        .call(body)
        .gsub(%r{<span class="name-ru">.*?</span>}, '')
        .gsub(%r{<span class="name-en">(.*?)</span>}, '\1')
        .html_safe
    end
  end
end
