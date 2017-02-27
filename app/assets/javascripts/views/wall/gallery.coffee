using 'Wall'
class Wall.Gallery extends View
  MIN_CLUSTER_1_SIZE = 2
  MIN_CLUSTER_2_SIZE = 3

  MIN_CLUSTER_HEIGHT = 80

  initialize: ->
    Wall.Gallery.last_id ||= 0
    Wall.Gallery.last_id += 1
    @id = Wall.Gallery.last_id

    @$root.imagesLoaded =>
      @_prepare()
      @_build_clusters()
      @_mason()

  _prepare: ->
    @$node.css
      width: ''
      height: ''

    @max_height = parseInt @$node.css('max-height')
    @max_width = parseInt @$node.css('width')

    $images = @$node
      .children('a, .b-video')
      .attr(rel: "wall-#{@id}")
      .css(width: '', height: '')
    $images.children().removeClass 'check-width'

    @images = $images.toArray().map (v) ->
      if v.classList.contains('b-video')
        new Wall.Video $(v)
      else
        new Wall.Image $(v)

  _build_clusters: ->
    cluster_1_size = 0
    cluster_2_size = @images.length

    if @_is_two_clusters()
      cluster_1_size = [(@images.length - MIN_CLUSTER_2_SIZE), 3].min()
      cluster_2_size = @images.length - cluster_1_size

      @cluster_1 = new Wall.Cluster(@images[0..cluster_1_size-1])
      @cluster_2 = new Wall.Cluster(@images[cluster_1_size..@images.length])

    else
      @cluster = new Wall.Cluster(@images)

  _mason: ->
    if @_is_two_clusters()
      @_mason_2_clusters false
      width = [@cluster_1.width(), @cluster_2.width()].max()
      height = @cluster_1.height() + Wall.Cluster.MARGIN + @cluster_2.height()

    else
      @_mason_1_cluster()
      width = @cluster.width()
      height = @cluster.height()

    @$node.css
      width: ([width, @max_width]).min()
      height: ([height, @max_height]).min()

  _is_two_clusters: ->
    @images.length >= MIN_CLUSTER_1_SIZE + MIN_CLUSTER_2_SIZE

  _cluster_1_height: ->
    [@max_height - MIN_CLUSTER_HEIGHT, MIN_CLUSTER_HEIGHT].max()

  _cluster_2_height: ->
    [
      (@max_height - @cluster_1.height() + Wall.Cluster.MARGIN).round(),
      MIN_CLUSTER_HEIGHT
    ].max()

  _mason_1_cluster: ->
    @cluster.mason 0, @max_width, @max_height

  _mason_2_clusters: (is_reposition) ->
    @cluster_1.mason 0, @max_width, @_cluster_1_height()
    @cluster_2.mason(
      @cluster_1.height() + Wall.Cluster.MARGIN,
      @max_width,
      @_cluster_2_height()
    )

    if !is_reposition && @cluster_2.width() < @max_width * 0.95
      @max_height = (@max_height * 1.3).round()
      @$node.css 'max-height', @max_height
      @images.each (image) -> image.reset()
      @_mason_2_clusters true
