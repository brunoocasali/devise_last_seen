require 'devise'
require 'devise_last_seen/model'
require 'devise_last_seen/hook'

module Devise
  # Interval (in seconds) to update the :last_seen_at_attribute attr
  mattr_accessor :last_seen_at_interval, default: 5.minutes

  # Attribute who will be updated every time a user is set by the Warden's after_save callback
  mattr_accessor :last_seen_at_attribute, default: :last_seen
end

module DeviseLastSeen; end

Devise.add_module(:lastseenable, model: true)
