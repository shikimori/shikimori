# should stay until https://github.com/rack/rack/pull/814 is merged and released
# NOTE: http://stackoverflow.com/questions/27773368/rails-4-2-internal-server-error-with-maximum-file-multiparts-in-content-reached
Rack::Utils.multipart_part_limit = 0
