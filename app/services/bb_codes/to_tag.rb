class BbCodes::ToTag
  method_object :tags

  def call
    @tags.map { |tag| "BbCodes::Tags::#{tag.to_s.camelize}Tag".constantize }
  end
end
