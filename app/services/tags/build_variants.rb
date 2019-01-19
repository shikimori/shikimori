class Tags::BuildVariants
  method_object :tags

  def call
    @tags.each_with_object({}) do |tag, memo|
      Tags::GenerateNames.call(tag).each do |fixed_tag|
        memo[fixed_tag] ||= []
        memo[fixed_tag].push tag
      end
    end
  end
end
