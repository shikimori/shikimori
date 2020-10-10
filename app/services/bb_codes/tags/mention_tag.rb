class BbCodes::Tags::MentionTag
  include Singleton

  REGEXP = %r{\[mention=\d+\](?<nickname>.+?)\[/mention\]}

  def format text
    text.gsub REGEXP do |match|
      nickname = $LAST_MATCH_INFO[:nickname]

      if nickname.present?
        url = UrlGenerator.instance.profile_url User.param_to(nickname)
        "<a href='#{url}' class='b-mention'>"\
          "<s>@</s><span>#{nickname}</span></a>"
      else
        match
      end
    rescue ActionController::UrlGenerationError
      match
    end
  end
end
