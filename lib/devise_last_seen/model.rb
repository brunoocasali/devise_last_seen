module Devise
  module Models
    module Lastseenable
      def track_last_seen!
        return unless last_seen.to_i < (Time.now - 5.minutes).to_i

        self.last_seen = DateTime.now

        save(validate: false)
      end
    end
  end
end
