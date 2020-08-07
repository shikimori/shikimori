class BbCodes::ToTagParser
  method_object :tags

  def call
    @tags.map do |tag|
      "BbCodes::Tags::#{tag.to_s.camelize}Tag".constantize
    end
  end
end
