require "json"

## FIXME class-level documentation missing
class SearchController < ApplicationController
  
  
  ## FIXME need to document here the secrets of Rails as to when this
  ## gets called and why it actually has a function.
  def index
    response = Net::HTTP.get_response(self.request.host, timestamp_path())
    @timestamp = Date.strptime(JSON.parse(response.body)["refresh_date"])
  end
  
  def timestamp_path()
    return "/OBD-WS/timestamp/"
  end
  
end
