class Banhammer
  pattr_initialize :comment

  ABUSE = /\b(
    [хx][уy]й |
    [хx][еe][рp] |
    н[аaеe][хx][еe][рp] |
    бля |
    [сc][уy][ч4]?[kк][аa] |
    н[аa][хx] |
    п[оo][хh]
  )\b/imx

  def release
    ban unless abusiveness.zero?
  end

private
  def ban
    duration = ban_duration

    comment.update_column :body, censored_body
    Ban.create!(
      user: comment.user,
      comment: comment,
      duration: duration,
      reason: "п. 3 [url=http://shikimori.org/s/79042-pravila-sayta]правил сайта[/url]",
      moderator: User.find(User::Banhammer_ID)
    )
  end

  def ban_duration
    multiplier = BanDuration.new(comment.user.bans.any? ? '2h' : '15m').to_i
    BanDuration.new(multiplier * abusiveness).to_s
  end

  def abusiveness
    comment.body.scan(ABUSE).size
  end

  def censored_body
    comment.body.gsub ABUSE do |match|
      "[color=#ff4136]#{match.size.times.inject(''){|v| v + '#' }}[/color]"
    end
  end
end
