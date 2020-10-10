class BbCodes::Tags::MentionTag
  include Singleton

  REGEXP = %r{\[mention=(?<user_id>\d+)\](?<nickname>.+?)\[/mention\]}

  def format text
    text.gsub REGEXP do |match|
      nickname = $LAST_MATCH_INFO[:nickname]
      user_id = $LAST_MATCH_INFO[:user_id]

      if nickname.present?
        url = UrlGenerator.instance.profile_url User.param_to(nickname)

        bbcode_to_html nickname, user_id, url
      else
        match
      end
    rescue ActionController::UrlGenerationError
      match
    end
  end

private

  def bbcode_to_html nickname, user_id, url
    <<~HTML.squish
      <a href='#{url}' class='b-mention'
        data-id='#{user_id}' data-type='user'
        data-text='#{nickname}'><s>@</s><span>#{nickname}</span></a>
    HTML
  end
end
