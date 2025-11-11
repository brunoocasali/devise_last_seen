# frozen_string_literal: true

module DeviseLastSeen
  module Controllers
    extend ActiveSupport::Concern

    included do
      after_action :track_last_seen
    end

    # Track the last seen of the current user for each devise scope that is authenticated and that defines the
    # devise module :lastseenable
    #
    # @return [void]
    def track_last_seen
      Devise.mappings.each do |scope, mapping|
        next unless mapping.modules.include?(:lastseenable)

        record = public_send("current_#{scope}")

        record.track_last_seen! if record.respond_to?(:track_last_seen!)
      rescue StandardError => e
        Rails.logger.error("[devise_last_seen] Error tracking last seen for #{scope}: #{e.message}")
      end
    end
  end
end
