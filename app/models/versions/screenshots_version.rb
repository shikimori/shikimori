class Versions::ScreenshotsVersion < Version
  ACTIONS = {
    upload: 'upload',
    reposition: 'reposition',
    delete: 'delete'
  }
  KEY = 'screenshots'

  def action
    item_diff['action']
  end

  def screenshots
    @screenshots ||= Screenshot.where id: item_diff[KEY]
  end

  #item_diff: {
    #action: 'upload',
    #ids: [...]
  #}

  #item_diff: {
    #action: 'position',
    #ids: [[...], [...]]
  #}

  #item_diff: {
    #action: 'delete',
    #ids: [...]
  #}
end
