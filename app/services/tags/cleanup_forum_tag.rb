class Tags::CleanupForumTag
  method_object :token

  TAG_MAPPINGS = {
    'anime' => 'аниме',
    'анимэ' => 'аниме',
    'анімэ' => 'аниме',
    'manga' => 'манга',
    'ranobe' => 'ранобэ',
    'ранобе' => 'ранобэ'
  }

  def call
    tag = (@token[0] == '#' ? @token[1..] : @token).downcase
    TAG_MAPPINGS[tag] || tag
  end
end
