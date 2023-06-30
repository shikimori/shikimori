class Tags::CleanupForumTag
  method_object :token

  ANIME_TAG = 'аниме'
  MANGA_TAG = 'манга'
  RANOBE_TAG = 'ранобэ'
  CHARACTER_TAG = 'персонаж'
  PERSON_TAG = 'человек'

  TAG_MAPPINGS = {
    'anime' => ANIME_TAG,
    'анимэ' => ANIME_TAG,
    'анімэ' => ANIME_TAG,
    'manga' => MANGA_TAG,
    'ranobe' => RANOBE_TAG,
    'ранобе' => RANOBE_TAG,
    'персонажи' => CHARACTER_TAG,
    'character' => CHARACTER_TAG,
    'characters' => CHARACTER_TAG,
    'person' => PERSON_TAG
  }

  def call
    tag = (@token[0] == '#' ? @token[1..] : @token).downcase
    TAG_MAPPINGS[tag] || tag
  end
end
