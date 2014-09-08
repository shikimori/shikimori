class SeyuDecorator < PersonDecorator
  WORK_GROUP_SIZE = 5

  def website_host
    begin
      URI.parse(object.website).host
    rescue
    end
  end

  def url
    h.seyu_url object
  end

  def works
    # группировка по персонажам и аниме
    @characters = []
    backindex = {}
    object.characters.includes(:animes).decorate.each do |char|
      entry = nil
      char.animes.each do |anime|
        if backindex.include?(anime.id)
          entry = backindex[anime.id]
          break
        end
      end

      unless entry
        entry = {
          characters: [char],
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
            entry[:animes][anime.id] = anime
            backindex[anime.id] = entry
          end
        end
      end
    end

    # для каждой группы оставляем только 6 в сумме аниме+персонажей
    @characters.each do |group|
      group[:characters] = group[:characters].take(5) if group[:characters].size > 5
      animes_limit = WORK_GROUP_SIZE - group[:characters].size
      group[:animes] = group[:animes]
        .map {|k,v| v } #.sort_by {|v| -1 * v.score }
        .take(animes_limit)
        .sort_by {|v| v.aired_on || v.released_on || DateTime.new(2001) }
    end

    @characters = @characters.sort_by do |v|
      animes = v[:animes].select {|v| v.score < 9.9 }
      #animes.empty? ? 0 : -1 * animes.max_by(&:score).score

      if animes.empty?
        0
      else
        -1 * if h.params[:sort] == 'time'
          animes.map {|v| (v.aired_on || v.released_on || DateTime.now + 10.years).to_datetime.to_i }.min
        else
          animes.max_by(&:score).score
        end
      end
    end
  end

private
  def proceess_role(role)
    role.strip.sub Regexp.new(Person::SeyuRoles.join('|')), 'Japanese'
  end
end
