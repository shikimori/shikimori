class Banhammer
  vattr_initialize :comment

  Z = '[!@#$%&*^]'
  X = '[\s.,-:?!)(]'
  ABUSE = /
    (?<= #{X}|\A|^ )
    (
      (н[аaеe])? # нахуй, хуй, хуйло, ***, хуйня
        (х|x|#{Z})(у|y|#{Z})(й|y|i|#{Z})
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
      (3|з|z|#{Z})(а|a|#{Z})(е|e|#{Z})(б|b|#{Z})(и|#{Z})(с|c|#{Z})(ь|#{Z}) | # заебись
      (п|p|#{Z})(е|e|ё|и|#{Z})(3|з|z|#{Z})(д|d|#{Z}) # пизда, пиздуй, пиздец
        ((а|a|#{Z}) | (у|y|#{Z})(й|y|i|#{Z}) | (е|e|#{Z})(ц|c|с|#{Z}))
    )
    (?= #{X}|\Z|$ )
    /imx

  ABUSE_SYMBOL = /#{Z}/
  NOT_ABUSE = /(#{X}|\A|^) (#{Z}{1,7}) (#{X}|\Z|$)/imx

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
    duration = if comment.user.bans.size >= 2 && comment.user.bans.last.created_at > 36.hours.ago
      '1d'
    elsif comment.user.bans.any?
      '2h'
    else
      '15m'
    end

    multiplier = BanDuration.new(duration).to_i
    BanDuration.new(multiplier * abusiveness).to_s
  end

  def censored_body
    comment.body.gsub ABUSE do |match|
      "[color=#ff4136]#{match.size.times.inject(''){|v| v + '#' }}[/color]"
    end
  end

  def abusiveness text = self.comment.body
    @abusivenesses ||= {}
    @abusivenesses[text] ||=
      text
        .gsub(BbCodes::UrlTag::REGEXP, '')
        .scan(ABUSE)
        .select do |group|
          group.select(&:present?).select do |match|
            match.size >= 3 && match !~ NOT_ABUSE &&
              match.scan(ABUSE_SYMBOL).size <= (match.size / 2).floor
          end.any?
        end
        .size
  end
end
