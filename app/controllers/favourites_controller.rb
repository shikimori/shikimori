class FavouritesController < ShikimoriController
  before_action :authenticate_user!

  # добаавление в избранные
  def create
    entries_limit = Favourite.const_get('EntriesPer' + params[:linked_type])

    if Favourite.where(
        linked_type: params[:linked_type],
        user_id: current_user.id,
        kind: params[:kind] || ''
      ).count >= entries_limit

      type_name = case params[:linked_type]
        when Character.name then 'персонажей'
        when Anime.name then 'аниме'
        when Manga.name then 'наименований манги'
        when Person.name then 'людей'
        else
          raise CanCan::AccessDenied
      end

      render json: ['Лишь %d %s могут быть добавлены в избранное' % [entries_limit, type_name]],
          status: :unprocessable_entity
    else
      @notice_text = case params[:linked_type]
        when Character.name then 'Персонаж добавлен в избранное'
        when Anime.name then 'Аниме добавлено в избранное'
        when Manga.name then 'Манга добавлена в избранное'
        when Person.name then 'Добавлено в избранное'
        else
          raise CanCan::AccessDenied
      end

      @fav = Favourite.new(
        linked_type: params[:linked_type],
        linked_id: params[:linked_id],
        user_id: current_user.id,
        kind: params[:kind] || ''
      )
      @fav.save!

      render json: { success: true, notice: @notice_text }
    end

  rescue ActiveRecord::RecordNotUnique
    render json: { success: true, notice: @notice_text }
  end

  # удаление из избранных
  def destroy
    @notice_text = case params[:linked_type]
      when Character.name
        'Персонаж удален из избранного'
      when Anime.name
        'Аниме удалено из избранного'
      when Manga.name
        'Манга удалена из избранного'
      when Person.name
        'Удалено из избранного'
      else
        raise CanCan::AccessDenied
    end

    @fav = Favourite.where(
      linked_type: params[:linked_type],
      linked_id: params[:linked_id],
      user_id: current_user.id,
    ).destroy_all

    render json: { success: true, notice: @notice_text }
  end
end
