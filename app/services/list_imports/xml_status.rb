class ListImports::XmlStatus
  method_object :shiki_status, :list_type, :is_mal_status

  def call
    if @list_type == ::ListImports::ParseXml::ANIME_TYPE
      anime_status
    elsif @list_type == ::ListImports::ParseXml::MANGA_TYPE
      manga_status
    else
      raise ArgumentError, "#{@list_type}"
    end
  end

private

  def anime_status
    case @shiki_status.to_sym
      when :planned then 'Plan to Watch'
      when :watching then 'Watching'
      when :completed then 'Completed'
      when :on_hold then 'On-Hold'
      when :dropped then 'Dropped'
      when :rewatching then @is_mal_status ? 'Completed' : 'Rewatching'
      else raise ArgumentError, @shiki_status
    end
  end

  def manga_status
    case @shiki_status.to_sym
      when :planned then 'Plan to Read'
      when :watching then 'Reading'
      when :completed then 'Completed'
      when :on_hold then 'On-Hold'
      when :dropped then 'Dropped'
      when :rewatching then @is_mal_status ? 'Completed' : 'Rereading'
      else raise ArgumentError, @shiki_status
    end
  end
end
