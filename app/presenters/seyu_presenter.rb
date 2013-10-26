class SeyuPresenter < PersonPresenter
  def website_host
    @website_host ||= begin
      URI.parse(@seyu.website).host
    rescue
    end
  end

  def url
    seyu_url person
  end

  def works
    @works ||= begin
      # группировка по персонажам и аниме
      @characters = []
      backindex = {}
      characters = person.characters.includes(:animes).each do |char|
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
              animes: char.animes.each_with_object({}) {|v,memo| memo[v.id] = v }
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
        animes_limit = 6 - group[:characters].size
        group[:animes] = group[:animes].map {|k,v| v }.
                                        sort_by {|v| -1 * v.score }.
                                          take(animes_limit).
                                          sort_by {|v| v.aired_at || v.released_at || DateTime.new(2001) }
      end
      @characters = @characters.sort_by do |v|
        animes = v[:animes].select {|v| v.score < 9.9 }
        #animes.empty? ? 0 : -1 * animes.max_by(&:score).score

        if animes.empty?
          0
        else
          -1 * if params[:sort] == 'time'
            animes.map {|v| (v.aired_at || v.released_at || DateTime.now + 10.years).to_datetime.to_i }.min
          else
            animes.max_by(&:score).score
          end
        end
      end
    end
  end

private
  def proceess_role(role)
    role.strip.sub Regexp.new(Person::SeyuRoles.join('|')), 'Japanese'
  end
end
