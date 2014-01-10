class ImagesController < ApplicationController
  before_filter :authenticate_user!

  # редактирование картинки
  def edit
    @image = Image.find(params[:id])

    raise Forbidden unless @image.uploader_id == current_user.id
    @page_title = params[:original] ?
      (@image.geometry(:original).width != @image.geometry(:main).width ?
        'Загружено новое изображение [%dx%d] -> [%dx%d]' % [@image.geometry(:original).width, @image.geometry(:original).height, @image.geometry(:main).width, @image.geometry(:main).height] :
        'Загружено новое изображение [%dx%d]' % [@image.geometry(:original).width, @image.geometry(:original).height]) :
      'Изменение изображения [%dx%d]' % [@image.geometry(:main).width, @image.geometry(:main).height]
  end

  # создание картинки
  def create
    owner = params[:model].capitalize.constantize.find params[:id]

    @image = Image.new
    @image.owner = owner
    @image.uploader = current_user
    @image.image = params[:image]

    if @image.save
      render json: {
        html: render_to_string(partial: 'images/image', object: @image, locals: { group_name: 'images', style: :main }, formats: :html)
      }
    else
      render json: @image.errors.messages, status: :unprocessable_entity
    end
  rescue
    render json: { error: 'Произошла ошибка при загрузке файла. Пожалуйста, повторите попытку, либо свяжитесь с администрацией сайта.' }, status: :unprocessable_entity
  end

  # старое создание картинки
  def new
    params[:image][:uploader_id] = current_user.id
    owner = params[:image][:owner] = Object.const_get(params[:model].capitalize).find(params[:id])

    if owner.respond_to?(:can_be_uploaded_by?)
      raise Forbidden unless owner.can_be_uploaded_by?(current_user)
    end

    @image = Image.new
    @image.owner = owner
    @image.uploader = current_user
    @image.image = params[:image][:image]
    @image.save!

    redirect_to url_for(owner)
  end

  # изменение картинки
  def update
    @image = Image.find(params[:id])
    raise Forbidden unless @image.uploader_id == current_user.id
    @image.update_attributes(params[:image])
    redirect_to edit_image_url(@image)
  end

  # содержимое картинки
  def raw
    @image = Image.find(params[:id])
    raise Forbidden unless @image.uploader_id == current_user.id

    response.headers['Content-Type'] = 'image/jpeg'
    render text: File.read(@image.image.path(:original))
  end

  # удаление картинки
  def destroy
    @image = Image.find(params[:id])
    raise Forbidden unless @image.can_be_deleted_by?(current_user)
    owner = @image.owner
    @image.destroy

    respond_to do |format|
      format.html { redirect_to owner }
      format.json { render json: { notice: 'Картинка удалена' } }
    end
  end

  # загрузка картинки на удалённый хостинг
  def remote_upload
    render json: { error: 'Загрузка картинок временно недоступна. Мы знаем о проблеме, в ближайшее время будем чинить.' }
    return

    #image = File.open(File.join(Rails.root, 'spec', 'images', 'anime.jpg'))
    image = params[:image]
    unless %x(file #{image.tempfile.path}) =~ /image/
      render json: { error: 'Загруженный файл не является изображением' }
      return
    end
    geometry = Paperclip::Geometry.from_file(image)

    key = Nokogiri::HTML(RestClient.get('http://imageshack.us/?no_multi=1')).css('input[name=key]').attr('value')
    content = RestClient.post('http://post.imageshack.us/', {
        fileupload: image,
        uploadtype: "on",
        url: '',
        email: '',
        #tags: '',
        MAX_FILE_SIZE: '13145728',
        refer: '',
        brand: '',
        optimage: 'resample',
        key: key,
        optsize: 'resample',
        #optsize: 'optimize',
        rembar: '1'
      }, [
        'Referer:http://imageshack.us/',
        'User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31'
      ]) { |response, request, result, &block|
        if [301, 302, 307].include? response.code
          RestClient.get result.header['location']
        else
          response.return!
        end
      }

    doc = Nokogiri::HTML(content)
    continue = doc.css('#continue-link a')
    if continue.any?
      content = RestClient.get("http://imageshack.us#{continue.attr('href').value}", [
        'User-Agent:Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_3) AppleWebKit/537.31 (KHTML, like Gecko) Chrome/26.0.1410.65 Safari/537.31'
      ])
    end

    #File.open('/tmp/test.html', 'w') {|v| v.write(content) }
    doc = Nokogiri::HTML(content)
    direct = doc.css('#ImageCodes input')[1].attr('value')
    #forum = doc.css('textarea').first.children[0].text
               #.sub(/Uploaded.*/, '')
               #.strip
               #.gsub('URL', 'url')
               #.gsub('IMG', 'img')
               #.sub(/\[url=.*?\]/i, "[url=#{direct}]")

    render json: {
      bb_code: geometry.height > 200 ? "[url=#{direct}][img]#{direct.sub(/\.(.{3,4})$/, '.th.\1')}[/img][/url]" : "[img]#{direct}[/img]"
    }
  rescue
    @retries ||= 1
    @retries -= 1

    if @retries > 0
      retry
    else
      render json: { error: 'Произошла ошибка при загрузке файла. Пожалуйста, повторите попытку, либо свяжитесь с администрацией сайта.' }
    end
  end
end
