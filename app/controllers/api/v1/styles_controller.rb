class Api::V1::StylesController < Api::V1Controller
  load_and_authorize_resource

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/styles/:id', 'Show a style'
  def show
    respond_with @resource
  end

  api :POST, '/styles', 'Preview a style'
  param :style, Hash do
    param :css, String, required: true
  end
  def preview
    @resource = Style.new css: params[:style][:css]
    @resource.assign_attributes Styles::Compile.call(@resource.css)
    respond_with @resource
  end

  api :POST, '/styles', 'Create a style'
  param :style, Hash do
    param :css, String, required: true
    param :name, String, required: true
    param :owner_id, :number, required: true
    param :owner_type, Style::OWNER_TYPES, required: true
  end
  def create
    @resource.save
    respond_with @resource
  end

  api :PATCH, '/styles/:id', 'Update a style'
  api :PUT, '/styles/:id', 'Update a style'
  param :style, Hash do
    param :css, String, required: false, allow_blank: true
    param :name, String, required: false, allow_blank: true
  end
  def update
    @resource.update update_params
    @resource.compile!
    respond_with @resource, location: nil
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  # api :DELETE, '/styles/:id', 'Destroy a style'
  # def destroy
    # @resource.destroy
    # head 204
  # end

private

  def create_params
    params.require(:style).permit(:owner_id, :owner_type, :name, :css)
  end

  def update_params
    params.require(:style).permit(:name, :css)
  end
end
