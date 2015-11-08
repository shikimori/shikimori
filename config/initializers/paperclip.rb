Paperclip.interpolates :user_id do |attachment, style|
  attachment.instance.user_id
end

Paperclip.interpolates :access_token  do |attachment, style|
  attachment.instance.access_token
end

# manga online
Paperclip.interpolates :manga_id_mod do |attachment, style|
  attachment.instance.manga_id_mod
end

Paperclip.interpolates :manga_id do |attachment, style|
  attachment.instance.manga_id
end

Paperclip.interpolates :chapter_name do |attachment, style|
  attachment.instance.chapter_name
end

Paperclip.interpolates :number do |attachment, style|
  attachment.instance.number
end
# ----

# отключаем проверку на spoofing, она работает как-то странно
module Paperclip::HasAttachedFile::WithoutSpoofingCheck
  def add_required_validations
  end
end
Paperclip::HasAttachedFile.send :prepend, Paperclip::HasAttachedFile::WithoutSpoofingCheck
Paperclip.options[:use_exif_orientation] = false
