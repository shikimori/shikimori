class SeyuDecorator < PersonDecorator
  WORK_GROUP_SIZE = 5

  rails_cache :best_roles
  instance_cache :character_works

  def url
    h.seyu_url object
  end

  def best_roles
    all_character_ids = characters.pluck(:id)
    character_ids = FavouritesQuery.new
      .top_favourite(Character, 6)
      .where(linked_id: all_character_ids)
      .pluck(:linked_id)

    drop_index = 0
    while character_ids.size < 6 && character_works.size > drop_index
      character_id = character_works.drop(drop_index).first[:characters].first.id
      character_ids.push character_id unless character_ids.include? character_id
      drop_index += 1
    end

    Character
      .where(id: character_ids)
      .sort_by {|v| character_ids.index v.id }
  end

  def character_works
    # группировка по персонажам и аниме
    @characters = []
    backindex = {}
    characters.includes(:animes).each do |char|
      entry = nil
      char.animes.each do |anime|
        if backindex.include?(anime.id)
          entry = backindex[anime.id]
          break
        end
      end

      unless entry
        entry = {
          characters: [char.decorate],
          animes: char.animes.each_with_object({}) {|v,memo| memo[v.id] = v.decorate }
        }
        char.animes.each do |anime|
          backindex[anime.id] = entry unless backindex.include?(anime.id)
        end
        #ap entry[:animes]
        @characters << entry
      else
        entry[:characters] << char
        char.animes.each do |anime|
          unless entry[:animes].include?(anime.id)
            entry[:animes][anime.id] = anime.decorate
            backindex[anime.id] = entry
          end
        end
      end
    end

    # для каждой группы оставляем только 6 в сумме аниме+персонажей
    @characters.each do |group|
      group[:characters] = group[:characters].take(3) if group[:characters].size > 3
      animes_limit = WORK_GROUP_SIZE - group[:characters].size
      group[:animes] = group[:animes]
        .map {|k,v| v } #.sort_by {|v| -1 * v.score }
        .take(animes_limit)
        .sort_by {|v| v[:aired_on] || v.released_on || DateTime.new(2001) }
    end

    @characters = @characters.sort_by do |v|
      animes = v[:animes].select {|a| a.score < 9.9 }

      if animes.empty?
        0
      else
        -1 * animes.max_by(&:score).score
      end
    end
  end

  def url
    h.seyu_url object
  end
end
