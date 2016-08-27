class SeyuProfileSerializer < PersonProfileSerializer
  def roles
    object.character_works.map do |work|
      {
        characters: work[:characters].map {|v| CharacterSerializer.new v },
        animes: work[:animes].map {|v| AnimeSerializer.new v }
      }
    end
  end

  def works
    []
  end
end
