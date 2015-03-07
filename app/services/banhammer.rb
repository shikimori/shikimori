class Banhammer
  vattr_initialize :comment

  Z = '[!@#$%&*^]'
  ABUSE = /
    (?<= \s|\A|^ )
    (
      (н[аaеe])? # нахуй, хуй, хуйло, ***, хуйня
        (х|x|#{Z})(у|y|#{Z})(й|#{Z})
        ((л|#{Z})(о|o|#{Z}) | (н|n|#{Z})(я|#{Z}))? |

      (н[аaеe]|п[оo])? # нахер, хер, херня, похер, херово, хера, херь
        (х|x|#{Z})(е|e|#{Z})(р|p|#{Z})
        ((а|a|ь|#{Z}) | (о|o|#{Z})(в|#{Z})(о|o|#{Z}) | (н|#{Z})(я|#{Z}))? |

      (б|b|#{Z})(л|l|#{Z})(я|#{Z}) ((т|t|д|d|#{Z}) (ь|#{Z}))? | # бля, блядь, блять
      (с|c|#{Z})(у|y|#{Z}) (ч|4|#{Z})? # сука, сучка, сучёнок
        ((k|к|#{Z})(а|a|#{Z}) | (е|e|ё|о|o|#{Z})(н|#{Z})(о|o|#{Z})(k|к|#{Z})) |
      (о|o|#{Z})(х|x|#{Z})(у|y|#{Z})(е|e|#{Z})(л|ть) |

      (п|p|#{Z})(о|o|#{Z})(х|h|#{Z}) | # пох
      (н|n|#{Z})(а|a|#{Z})(х|h|#{Z}) | # нах

      (е|e|ё|#{Z})(б|b|#{Z})(а|a|#{Z}) ((т|t|#{Z})(ь|#{Z}))? | # ебать, ёба
      (3|з|z|#{Z})(а|a|#{Z})(е|e|#{Z})(б|b|#{Z})(и|#{Z})(с|c|#{Z})(ь|#{Z}) # заебись
    )
    (?= \s|\Z|$ )
    /imx

  NOT_ABUSE = /(\s|\A|^) #{Z}{1,7} (\s|\Z|$)/imx

  def release
    ban if abusive?
  end

  def abusive? text = self.comment.body
    abusiveness(text) > 0
  end

private
  def ban
    duration = ban_duration

    comment.update_column :body, censored_body
    Ban.create!(
      user: comment.user,
      comment: comment,
      duration: duration,
      reason: "п.3 [url=http://shikimori.org/s/79042-pravila-sayta]правил сайта[/url]",
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

  def abusiveness text = self.comment.body
    text
      .scan(ABUSE)
      .select {|group| group.select(&:present?).select {|v| v !~ NOT_ABUSE }.any? }
      .size
  end
end
