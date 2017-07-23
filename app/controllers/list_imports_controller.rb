class ListImportsController < ShikimoriController
  load_and_authorize_resource

  def new
  end

  def create
    if @resource.save
      redirect_to list_import_url(@resource)
    else
      render :new
    end
  end

  def show
  end

private

  def list_import_params
    params
      .require(:list_import)
      .permit(:user_id, :list)
  end
end
