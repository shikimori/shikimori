module BbCodes
  MULTILINE_BBCODES = %w[spoiler spoiler_block quote div center right list]
  BLOCK_TAG_EDGE_PREFIX_REGEXP = %r{
    (?:
      <div[^>]*+> |
      </div> |
      </ul> |
      <li> |
      </?p> |
      </?center> |
      </?right> |
      </?h\d> |
      <<-CODE-\d-PLACEHODLER->>
    )
  }x
end
