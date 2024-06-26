ids = [8, 419948, 1028805, 1105696, 1118835, 1172315, 1227283, 1383110, 1421200, 1422272, 1448249, 1469066, 1469728]; # rubocop:disable Style/NumericLiterals

def fix_path paperclip_image
  paperclip_image.path(:original).gsub(Rails.root.to_s, '').gsub('/public/system/', '')
end

def local_path paperclip_image
  "/Volumes/backups_2tb/shikimori/system/#{fix_path paperclip_image}"
end

def shiki_path paperclip_image
  "/home/apps/shikimori/production/current/public/system/#{fix_path paperclip_image}"
end

def upload_command paperclip_image
  "scp #{local_path paperclip_image} shiki:#{shiki_path paperclip_image}"
end

ids.each do |id|
  user = User.find_by(id:)
  next unless user

  puts "User##{user.id}"
  puts upload_command(user.avatar)
  `#{upload_command(user.avatar)}`

  user.clubs_owned.each do |club|
    next unless File.exist? local_path(club.logo)

    puts "Club##{club.id}"
    puts upload_command(club.logo)
    `#{upload_command(club.logo)}`
  end

  user.user_images.each do |user_image|
    puts "UserImage##{user_image.id}"
    next unless File.exist? local_path(user_image.image)

    puts upload_command(user_image.image)
    `ssh shiki 'mkdir -p #{shiki_path(user_image.image).gsub(%r{/[^/]*$},
      '')}' && #{upload_command(user_image.image)}`
  end
end
