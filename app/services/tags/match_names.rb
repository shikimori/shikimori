class Tags::MatchNames
  method_object %i[names! tags_variants!]

  def call
    (Tags::GenerateNames.call(@names) & @tags_variants.keys)
      .flat_map do |fixed_tag|
        @tags_variants[fixed_tag]
      end
      .uniq
  end
end
