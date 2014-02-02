Paperclip.interpolates :user_id do |attachment, style|
  attachment.instance.user_id
end

Paperclip.interpolates :access_token  do |attachment, style|
  attachment.instance.access_token
end

# отключаем проверку на spoofing, она работает как-то странно
module Paperclip::HasAttachedFile::WithoutSpoofingCheck
  def add_required_validations
  end
end
Paperclip::HasAttachedFile.send :prepend, Paperclip::HasAttachedFile::WithoutSpoofingCheck
