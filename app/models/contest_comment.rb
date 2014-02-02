class ContestComment < AniMangaComment
  def text
    "Топик [contest=#{linked.id}]опроса[/contest].
    Статус: #{linked.decorate.status}"
  end

  def title
    "Опрос \"#{linked.title}\""
  end

  def to_s
    title
  end
end
