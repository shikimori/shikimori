class FavouritesController < ShikimoriController
  before_filter :authenticate_user!

  # добаавление в избранные
  def create
    entries_limit = Favourite.const_get('EntriesPer' + params[:linked_type])

    if Favourite.where({
          linked_type: params[:linked_type],
          user_id: current_user.id,
          kind: params[:kind]
        }).count >= entries_limit
      type_name = case params[:linked_type]
        when Character.name then 'персонажей'
        when Anime.name then 'аниме'
        when Manga.name then 'наименований манги'
        when Person.name then 'людей'
        else
          raise Forbidden
      end
      render json: ['Лишь %d %s могут быть добавлены в избранные' % [entries_limit, type_name]],
          status: :unprocessable_entity
    else
      @fav = Favourite.new({
        linked_type: params[:linked_type],
        linked_id: params[:linked_id],
        user_id: current_user.id,
        kind: params[:kind]
      })
      @fav.save!

      notice_text = case params[:linked_type]
        when Character.name then 'Персонаж добавлен в избранные'
        when Anime.name then 'Аниме добавлено в избранные'
        when Manga.name then 'Манга добавлена в избранные'
        when Person.name then 'Добавлено в избранное'
        else
          raise Forbidden
      end
      render json: { success: true, notice: notice_text }
    end

  rescue Exception => e
    raise e if [Unauthorized, Forbidden].include?(e.class)

    if Rails.env.development?
      render json: { e.class => e.message }, status: :unprocessable_entity
    else
      render json: {}, status: :unprocessable_entity
    end
  end

  # удаление из избранных
  def destroy
    @fav = Favourite.where({
        linked_type: params[:linked_type],
        linked_id: params[:linked_id],
        user_id: current_user.id,
        kind: params[:kind]
      }).first
    @fav.destroy

    notice_text = case params[:linked_type]
      when Character.name
        'Персонаж удален из избранных'
      when Anime.name
        'Аниме удалено из избранных'
      when Manga.name
        'Манга удалена из избранных'
      when Person.name
        'Удалено из избранных'
      else
        raise Forbidden
    end
    render json: { success: true, notice: notice_text }
  rescue
    render json: {}, status: :unprocessable_entity
  end
end
