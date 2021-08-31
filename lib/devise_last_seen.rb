require 'devise'
require 'devise_last_seen/model'
require 'devise_last_seen/hook'

module DeviseLastSeen; end

Devise.add_module(:lastseenable, model: true)
