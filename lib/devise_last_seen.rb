require 'devise'
require 'devise_last_seen/model'
require 'devise_last_seen/hook'

module DeviseLastSeen
  class Error < StandardError; end
end

Devise.add_module(:lastseenable, model: true)
