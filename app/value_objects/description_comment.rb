# комментарий с description описанием вместо обычного body
# использутеся для превью текстов описаний
class DescriptionComment < SimpleDelegator
  def initialize comment, target_type, target_id, lang
    super comment
    @target = target_type.constantize.find(target_id)
    @lang = lang
  end

  def html_body
    BbCodes::EntryText.call body, entry: @target, lang: @lang
  end
end
