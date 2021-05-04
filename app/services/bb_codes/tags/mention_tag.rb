class BbCodes::Tags::MentionTag
  include Singleton

  REGEXP = %r{\[mention=(?<user_id>\d+)\](?<nickname>.+?)\[/mention\]}

  def format text
    text.gsub REGEXP do |match|
      nickname = $LAST_MATCH_INFO[:nickname]
      user_id = $LAST_MATCH_INFO[:user_id].to_i

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
    data_attrs = {
      id: user_id,
      type: 'user',
      text: nickname
    }.to_json

    <<~HTML.squish
      <a href='#{url}' class='b-mention'
        data-attrs='#{ERB::Util.h data_attrs}'><s>@</s><span>#{ERB::Util.h nickname}</span></a>
    HTML
  end
end
