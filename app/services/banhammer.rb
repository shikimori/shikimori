class Banhammer
  vattr_initialize :comment

  Z = '[!@#$%&*^]'
  ABUSE = /(\b|\n|\r|\A|^)(
    fffffffalse
  )(\b|\n|\r|\Z|$)/imx

  def release
    ban if abusive?
  end

  def abusive? text = self.comment.body
    !!(text =~ ABUSE)
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

  def censored_body
    comment.body.gsub ABUSE do |match|
      "[color=#ff4136]#{match.size.times.inject(''){|v| v + '#' }}[/color]"
    end
  end

  def abusiveness
    comment.body.scan(ABUSE).size
  end
end
