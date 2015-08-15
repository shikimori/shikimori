class Versions::ScreenshotsVersion < Version
  ACTIONS = {
    upload: 'upload',
    reposition: 'reposition',
    delete: 'delete'
  }

  #item_diff: {
    #action: 'upload',
    #ids: [...]
  #}

  #item_diff: {
    #action: 'position',
    #ids: [...]
  #}

  #item_diff: {
    #action: 'delete',
    #ids: [...]
  #}
end
