Warden::Manager.after_set_user do |record, _warden, _opts|
  record.track_last_seen! if record.respond_to?(:track_last_seen!)
end
