module Devise
  module Models
    module Lastseenable
      def track_last_seen!
        return if new_record?
        return unless last_seen.to_i < (Time.now - 5.minutes).to_i

        self.last_seen = DateTime.now

        save(validate: false)
      end
    end
  end
end
