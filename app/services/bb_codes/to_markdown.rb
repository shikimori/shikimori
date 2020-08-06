class BbCodes::ToMarkdown
  method_object :tags

  def call
    @tags.map do |tag|
      "BbCodes::Markdown::#{tag.to_s.camelize}Parser".constantize
    end
  end
end
