class MigrateImagesToPosters < ActiveRecord::Migration[6.1]
  def up
    # return if Rails.env.test?
    # 
    # [Anime, Manga, Character, Person].each do |klass|
    #   klass
    #     .where.not("desynced && '{poster}'")
    #     .includes(:poster)
    #     .find_each do |entry|
    #       next if entry.poster.present?
    #       next unless entry.image.exists?
    # 
    #       puts "#{klass} #{entry.id}"
    # 
    #       entry.create_poster image: File.open(entry.image.path)
    #     end
    # end
  end
end

# [Anime, Manga, Character, Person].each do |klass|
#   puts klass.name
#   klass.
#     where("desynced && '{image}'").
#     where.not("desynced && '{poster}'").
#     find_each do |v|
#       puts v.id
#       v.desynced += %w[poster]
#       v.save!
#     end;
# end;
# 
# [Anime, Manga, Character, Person].each do |klass|
#   puts klass.name
#   puts klass.
#     where("desynced && '{image}'").
#     where.not("desynced && '{poster}'").
#     count;
# end;
# 
# [Character].each do |klass|
#   klass.
#     where(id: [2454, 42346, 46559, 157397, 170695, 173072, 178559, 179439, 184131, 184134, 184136, 185698, 186233, 187369, 187370, 187372, 187521, 193013, 200606, 205653, 208230, 214151, 219928, 223136, 223344, 223369, 223440, 223447]).
#     includes(:poster).
#     find_each do |entry|
#       puts "#{klass} #{entry.id}"
#       entry.poster&.destroy!
#       entry.create_poster image: File.open(entry.image.path)
#     end
# end
