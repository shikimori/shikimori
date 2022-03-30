class CosplayController < ShikimoriController
#   include ActionView::Helpers::TextHelper
#   include CosplayHelper
#
#   helper_method :breadcrumbs, :chronology
#   before_action lambda { raise Unauthorized unless user_signed_in? && current_user.cosplay_moderator? }, only: [:mod, :new, :update, :edit, :create, :delete, :undelete]
#
#   # модерация косплея
#   def mod
#     og noindex: true, nofollow: true
#     og page_title: 'Косплей'
#     og page_title: 'Модерация'
#
#     User
#       .where("roles && '{#{Types::User::Roles[:cosplay_moderator]}}'")
#       .where.not(id: User::MORR_ID)
#       .sort_by { |v| v.nickname.downcase }
#
#     limit = 480
#     @cosplay = CosplayGallery
#       .where(confirmed: false, deleted: false)
#       .includes(:cosplayers)
#       .order(id: :desc)
#       .limit(limit)
#   end
#
#   # новый косплей
#   def new
#     og page_title: 'Новая галерея'
#     @gallery = CosplayGallery.new
#   end
#
#   # редактирование косплея
#   def edit
#     @chronology_size ||= 100
#     @chronology_window ||= 30
#
#     @cosplayer = Cosplayer.find params[:cosplay_id].to_i
#     @gallery = CosplayGallery.find(params[:id].to_i).becomes CosplayGallery
#     @gallery.becomes CosplayGallery
#
#     og page_title: 'Косплей'
#     og page_title: 'Модерация'
#     og page_title: @gallery.to_param
#     #cosplayers_show
#
#     @characters = @gallery.characters
#     @animes = @gallery.animes
#     @mangas = @gallery.mangas
#     @tags = @gallery.tag_list
#
#     return if @gallery.confirmed?
#     @gallery.description_cos_rain.gsub!(/＇|&#65287;/, "'") if @gallery.description_cos_rain
#     if @characters.empty? || @animes.empty? || @mangas.empty? || @tags.empty?
#       if strip_tags(@gallery.description_cos_rain || '').match(/^(?:.*?) (?:is|are) cosplaying as (.*?) from (.*?)(?:$|\.)/)
#         animes = $2
#         # NOTE: unused
#         #mangas = $2
#         characters = $1
#         @anime_keywords = fix_keywords(animes.split(/&|and/).map {|v| v.strip }).
#                               map {|v| v.split(' ').size > 4 ? v : geta(v.split(' ')).map {|s| s.join(' ') } }.
#                               flatten
#         @manga_keywords = @anime_keywords
#         @gallery.target = 'Miku Hatsune' if animes == 'Vocaloid2' && characters == 'Miku Hatsune' && !@gallery.confirmed?
#
#         @character_keywords = fix_keywords(characters.split(/&|and/).map {|v| v.strip }).
#                                   map {|v| v.split(' ').size > 4 ? v : geta(v.split(' ')).map {|s| s.join(' ') } }.
#                                   flatten
#       end
#
#       unless @anime_keywords || @manga_keywords || @character_keywords
#         @keywords = extract_keywords(@gallery.description_cos_rain || '')
#         @all_keywords_combinations = @keywords.map {|v| v.split(' ').size > 4 ? v : geta(v.split(' ')).map {|s| s.join(' ') } }.flatten
#       else
#         @keywords = @anime_keywords + @manga_keywords + @character_keywords
#         @all_keywords_combinations = @anime_keywords + @manga_keywords + @character_keywords
#       end
#     end
#
#     #if @tags.empty?
#       #@tags = Tag.where(name: @all_keywords_combinations).pluck(:name)
#       #@all_keywords_combinations = @all_keywords_combinations.select {|v| !@tags.include?(v) }
#       #@keywords = @keywords.select {|v| !@tags.include?(v) }
#     #end
#
#     if @animes.empty?
#       query = Anime.squeel { name.in my{@anime_keywords || @all_keywords_combinations} }
#       query |= Anime.squeel { name.eq my{@gallery.target} }
#       @animes = Anime.where(query).all
#       if @animes.empty?
#         (@anime_keywords || @keywords).select {|v| v.split(' ').size >= 3 }.map {|v| '%' + v + '%'}.each do |v|
#           query |= Anime.squeel { name.like my{v.gsub(' ', '%')} }
#           query |= Anime.squeel { english.like v }
#           query |= Anime.squeel { synonyms.like v }
#           if v.split(' ').size > 2
#             query |= Anime.squeel { english.like "%#{v}%" }
#             query |= Anime.squeel { synonyms.like "%#{v}%" }
#           end
#         end
#         @animes = Anime.where(query).all
#       end
#     end
#
#     if @mangas.empty?
#       query = Manga.squeel { name.in my{@manga_keywords || @all_keywords_combinations} }
#       query |= Manga.squeel { name.eq my{@gallery.target} }
#       @mangas = Manga.where(query).all
#       if @mangas.empty?
#         (@manga_keywords || @keywords).select {|v| v.split(' ').size >= 3 }.map {|v| '%' + v + '%'}.each do |v|
#           query |= Manga.squeel { name.like my{v.gsub(' ', '%')} }
#           query |= Manga.squeel { english.like v }
#           query |= Manga.squeel { synonyms.like v }
#           if v.split(' ').size > 2
#             query |= Manga.squeel { english.like "%#{v}%" }
#             query |= Manga.squeel { synonyms.like "%#{v}%" }
#           end
#         end
#         @mangas = Manga.where(query).all
#       end
#     end
#
#     if @characters.empty?
#       query = Character.squeel { name.in my{@character_keywords || @all_keywords_combinations} }# | {:name.like => "#{@gallery.target}_"}# | {:fullname.like => "%\"#{@gallery.target}\"%"}# | {:name.like => @gallery.target.gsub(/(.)/, '\1%')}
#       if @character_keywords
#         @character_keywords.each do |v|
#           query |= Character.squeel { name.like "#{v} %" }
#           query |= Character.squeel { name.like "% #{v}" }
#           query |= Character.squeel { fullname.like "%\"#{v}%" }
#           query |= Character.squeel { fullname.like "#{v} \"%" }
#           query |= Character.squeel { fullname.like "% #{v}\"%" }
#         end
#       end
#       query |= Character.squeel { fullname.in my{@character_keywords || @keywords} }
#       query |= Character.squeel { name.eq my{@gallery.target} }# unless @ctags.include?(@gallery.target)
#       if @animes.empty? && @mangas.empty?
#         @characters = (@animes.map {|v| v.characters.where(query).all }.flatten + @mangas.map {|v| v.characters.where(query).all }.flatten).uniq
#       end
#       @characters = Character.where(query) if @characters.empty?
#     end
#
#     if @animes.empty? && !@characters.empty?
#       @animes = @characters.map {|v| v.animes }.flatten
#     end
#     if @mangas.empty? && !@characters.empty?
#       @mangas = @characters.map {|v| v.mangas }.flatten
#     end
#
#     @animes = @gallery.animes
#     @mangas = @gallery.mangas
#   end
#
#   # создание галереи
#   def create
#     cosplayer = Cosplayer.find_or_create_by_name(name: params[:cosplay_gallery][:name])
#     gallery = CosplayGallery.create(
#       target: params[:cosplay_gallery][:target],
#       date: DateTime.now,
#       source: params[:cosplay_gallery][:source],
#       user_id: current_user.id
#     )
#
#     pos = CosplayImage::PositionStep
#     cosplayer.cosplay_galleries << gallery
#     params[:cosplay_gallery][:images].each do |url|
#       next if url == ''
#       image = CosplayImage.create(url: url)
#       gallery.images << image
#
#       image_file_name = image.id.to_s + File.extname(url)
#       dir = Rails.root.to_s + '/public/images/' + image.class.name.downcase + '/original/'
#       if File.exists?(dir+image_file_name)
#         File.delete(dir+image_file_name)
#         print "deleted image %s\n" % [dir+image_file_name]
#       end
#       image.image = open_image(image.url)
#       image.cosplay_gallery_id = gallery.id
#       image.position = pos
#       image.save
#
#       pos += CosplayImage::PositionStep
#     end
#
#     redirect_to edit_cosplay_cosplay_gallery_url(cosplayer, gallery) and return
#   end
#
#   # обновление галереи
#   def update
#     gallery = CosplayGallery.find params[:id]
#
#     if params[:move_from][:confirm] == '1' && params[:move_from][:id] && params[:move_from][:id] != ''
#       @source = CosplayGallery.find(params[:move_from][:id].to_i)
#       @target = gallery
#     end
#     if params[:move_to][:confirm] == '1' && params[:move_to][:id] && params[:move_to][:id] != ''
#       @source = gallery
#       @target = CosplayGallery.find(params[:move_to][:id].to_i)
#     end
#     if @source && @target
#       if @target.cosplayers.all != @source.cosplayers.all
#         @source.cosplayers.each do |cosplayer|
#           @target.cosplayers << cosplayer unless @target.cosplayers.all.include?(cosplayer)
#         end
#       end
#       raise CanCan::AccessDenied if @target.id == @source.id
#       @source.move_to(@target)
#       redirect_to edit_cosplay_cosplay_gallery_url(params[:cosplay_id], @target) and return
#     end
#
#     gallery.tag_list = ""
#     gallery.links.where { linked_type.not_eq 'Cosplayer' }.delete_all
#     if params[:characters]
#       params[:characters].each do |v|
#         gallery.characters << Character.find(v)
#       end
#     end
#     if params[:animes]
#       params[:animes].each do |v|
#         gallery.animes << Anime.find(v)
#       end
#     end
#     if params[:mangas]
#       params[:mangas].each do |v|
#         gallery.mangas << Manga.find(v)
#       end
#     end
#     if params[:tags]
#       gallery.tag_list = params[:tags].join(',')
#     end
#
#     if gallery.save && gallery.update_attributes!(cosplay_gallery_params)
#       redirect_to edit_cosplay_cosplay_gallery_url params[:cosplay_id], gallery.to_param
#     else
#       render gallery.errors.full_messages, status: :unprocessable_entity
#     end
#   end
#
#   # удаление галереи
#   def delete
#     gallery = CosplayGallery.find params[:cosplay_gallery_id]
#
#     if gallery.update_attribute(:deleted, true)
#       redirect_to edit_cosplay_cosplay_gallery_url(params[:cosplay_id], gallery.to_param)
#     else
#       render gallery.errors.full_messages, status: :unprocessable_entity
#     end
#   end
#
#   # отмена удаление галереи
#   def undelete
#     gallery = CosplayGallery.find params[:cosplay_gallery_id]
#
#     if gallery.update_attribute(:deleted, false)
#       redirect_to edit_cosplay_cosplay_gallery_url(params[:cosplay_id], gallery.to_param)
#     else
#       render gallery.errors.full_messages, status: :unprocessable_entity
#     end
#   end
#
#   # TODO: выпилить
#   #def chronology params
#     #collection = params[:source]
#       #.where("`#{params[:date]}` >= #{ApplicationRecord.sanitize params[:entry][params[:date]]}")
#       #.where("#{params[:entry].class.table_name}.id != #{ApplicationRecord.sanitize params[:entry].id}")
#       #.limit(20)
#       #.order(params[:date])
#       #.to_a + [params[:entry]]
#
#     #collection += params[:source]
#       #.where("`#{params[:date]}` <= #{ApplicationRecord.sanitize params[:entry][params[:date]]}")
#       #.where.not(id: collection.map(&:id))
#       #.limit(20)
#       #.order("#{params[:date]} desc")
#       #.to_a
#
#     #collection = collection.sort {|l,r| r[params[:date]] == l[params[:date]] ? r.id <=> l.id : r[params[:date]] <=> l[params[:date]] }
#     #collection = collection.reverse if params[:desc]
#     #gallery_index = collection.index {|v| v.id == params[:entry].id }
#     #reduce = Proc.new {|v| v < 0 ? 0 : v }
#     #collection.slice(reduce.call(gallery_index + params[:window] + 1 < collection.size ?
#                                    #gallery_index - params[:window] :
#                                    #(gallery_index - params[:window] - (gallery_index + params[:window]  + 1 - collection.size))),
#                      #params[:window]*2 + 1).
#                #group_by do |v|
#                  #Russian::strftime(v[params[:date]], '%B %Y')
#                #end
#   #end
#
# private
#
#   def breadcrumbs
#     { 'Модерация косплея' => mod_cosplay_index_url }
#   end
#
#   def cosplay_gallery_params
#     params
#       .require(:cosplay_gallery)
#       .permit(:confirmed, :target, :description,
#               images_attributes: [:position, :deleted, :id],
#               deleted_images_attributes: [:deleted, :id],
#              )
#   end
#
#   def chronology
#     super window: @chronology_window, source: @cosplayer.cosplay_galleries, date: :date, entry: @gallery
#   end
end
