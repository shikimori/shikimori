class BbCodes::UserMention
  method_object :text

  REGEXP = /@([^\n\r,]{1,20})/

  def call
    text.gsub(REGEXP) do |matched|
      user, other_text = match_user Regexp.last_match(1)

      if user
        "[mention=#{user.id}]#{user.nickname}[/mention]#{other_text}"
      else
        matched
      end
    end
  end

private

  def match_user possible_nickname
    text = []

    while possible_nickname.present?
      user = find_user possible_nickname

      break if user
      break if possible_nickname !~ / |\./
      possible_nickname = possible_nickname.sub(/(.*)((?: |\.).*)/, '\1')
      text << Regexp.last_match(2)
    end

    [user, text.reverse.join]
  end

  def find_user nickname
    @cache ||= {}

    if @cache.key? nickname
      @cache[nickname]
    else
      @cache[nickname] = User.find_by nickname: nickname
    end
  end
end
