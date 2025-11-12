module Devise
  module Models
    module Lastseenable
      def track_last_seen!
        return if new_record?
        return unless respond_to?(last_seen_at_attribute_writer)
        return unless public_send(Devise.last_seen_at_attribute).to_i < (Time.now - Devise.last_seen_at_interval).to_i

        public_send(last_seen_at_attribute_writer, DateTime.now)

        track_last_seen_session!

        save(validate: false)
      end

      def last_seen_at_attribute_writer
        @last_seen_at_attribute_writer ||= :"#{Devise.last_seen_at_attribute}="
      end

      def track_last_seen_session!
        return unless Devise.last_seen_at_enable_session_tracking && defined?(DeviseLastSeen::Session)

        DeviseLastSeen::Session.create_for(self)
      end
    end
  end
end
