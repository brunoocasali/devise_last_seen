require 'devise'
require 'devise_last_seen/model'
require 'devise_last_seen/hook'
require 'devise_last_seen/controller'

module Devise
  # Interval (in seconds) to update the :last_seen_at_attribute attr
  mattr_accessor :last_seen_at_interval, default: 5.minutes

  # Attribute who will be updated every time a user is set by the Warden's after_save callback
  mattr_accessor :last_seen_at_attribute, default: :last_seen

  # Whether to track the last seen session, if enabled, the gem will create a new session in history
  # after the session duration is reached.
  mattr_accessor :last_seen_at_enable_session_tracking, default: false

  # Duration (in seconds) to keep the last seen session open,
  # after that it will generate a new session in history.
  mattr_accessor :last_seen_at_session_duration, default: 1.day
end

if Devise.last_seen_at_enable_session_tracking && defined?(ActiveRecord) && !defined?(DeviseLastSeen::Session)
  require 'devise_last_seen/session'
end

module DeviseLastSeen; end

Devise.add_module(:lastseenable, model: true)
