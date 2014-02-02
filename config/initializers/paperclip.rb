Paperclip.interpolates :user_id do |attachment, style|
  attachment.instance.user_id
end

Paperclip.interpolates :access_token  do |attachment, style|
  attachment.instance.access_token
end
