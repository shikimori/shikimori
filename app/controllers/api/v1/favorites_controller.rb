class Api::V1::FavoritesController < Api::V1Controller
  before_action :authenticate_user!
  load_and_authorize_resource only: %i[reorder], class: Favourite.name

  api :POST, '/favorites/:linked_type/:linked_id(/:kind)', 'Create a favorite'
  param :linked_id, :undef, required: true
  param :linked_type, :undef,
    required: true,
    desc: <<~DOC
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{Favourite.linked_type.values.join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  param :kind, :undef,
    required: false,
    desc: <<~DOC
      <p>Required when <code>linked_type</code> is <code>Person</code></p>
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{Favourite.kind.values.join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  def create # rubocop:disable MethodLength, AbcSize
    favorites_limit = Favourite::LIMITS[params[:linked_type]]
    raise CanCan::AccessDenied unless favorites_limit

    params[:kind] = ::Types::Favourite::Kind[:common] if params[:kind].blank?

    added_scope = Favourite
      .where(linked_type: params[:linked_type], user_id: current_user.id)
      .where(kind: params[:kind])

    added_count = added_scope.size

    if added_count >= favorites_limit
      render(
        json: [i18n_t(
          "cant_add.#{params[:linked_type].downcase}",
          limit: favorites_limit
        )],
        status: :unprocessable_entity
      )
    else
      linked = params[:linked_type].constantize.find(params[:linked_id])
      Favourite.create!(
        linked_id: linked.id,
        linked_type: linked.class.name,
        user_id: current_user.id,
        kind: params[:kind]
      )

      render json: { success: true, notice: i18n_t('added') }
    end
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    render json: { success: true, notice: i18n_t('added') }
  end

  api :DELETE, '/favorites/:linked_type/:linked_id', 'Destroy a favorite'
  param :linked_id, :undef, required: true
  param :linked_type, :undef,
    required: true,
    desc: <<~DOC
      <p><strong>Validations:</strong></p>
      <ul>
        <li>
          Must be one of:
          <code>#{Favourite.linked_type.values.join('</code>, <code>')}</code>
        </li>
      </ul>
    DOC
  def destroy
    Favourite
      .where(
        linked_type: params[:linked_type],
        linked_id: params[:linked_id],
        user_id: current_user.id
      )
      .destroy_all
    render json: { success: true, notice: i18n_t('removed') }
  end

  api :POST, '/favorites/:id/reorder', 'Assign a new position to a favorite'
  param :new_index, :undef
  def reorder
    Retryable.retryable tries: 2, on: PG::TRDeadlockDetected, sleep: 1 do
      @resource.insert_at params[:new_index].to_i + 1
    end
    head 200
  end
end
