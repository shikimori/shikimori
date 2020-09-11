module BbCodes
  MULTILINE_BBCODES = %w[spoiler spoiler_block quote div center right list]
  BLOCK_TAG_EDGE_REGEXP = %r{
    (?:
      </?div[^>]*+> |
      </?ul> |
      </?p> |
      </?center> |
      </?right> |
      </?h\d> |
      <<-CODE-\d-PLACEHODLER->>
    )
  }x
end
