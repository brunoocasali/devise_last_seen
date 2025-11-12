# frozen_string_literal: true

module DeviseLastSeen
  class Session < ::ActiveRecord::Base
    # Check session_duration configuration when Session class is loaded
    if Devise.last_seen_at_enable_session_tracking && Devise.last_seen_at_session_duration.blank?
      Rails.logger.warn(
        '[devise_last_seen] WARNING: Devise.last_seen_at_session_duration is ' \
        'nil or blank. Set it to a positive integer to avoid creating too many sessions.'
      )
    end

    self.table_name = 'devise_last_seen_sessions'

    belongs_to :user, polymorphic: true

    validates :user_id, presence: true
    validates :user_type, presence: true
    validates :last_seen_at, presence: true

    scope :last_seen_at, -> { order(last_seen_at: :desc) }
    scope :active, -> { last_seen_at.where('expires_at > ?', Time.current) }

    def self.create_for(record)
      current_session = active.where(user: record).first

      return update_current_session(current_session) if current_session.present?

      create_new_session(record)
    end

    def self.update_current_session(current_session)
      current_session.update(last_seen_at: Time.current)
    end

    def self.create_new_session(record)
      max_session_time = Time.current + Devise.last_seen_at_session_duration.to_i

      create!(
        user: record,
        started_at: Time.current,
        last_seen_at: max_session_time,
        expires_at: max_session_time
      )
    rescue StandardError => e
      Rails.logger.error("[devise_last_seen] Error creating new session for #{record.class.name}: #{e.message}")

      nil
    end
  end
end
