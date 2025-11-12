# frozen_string_literal: true

require 'spec_helper'
require 'integration_spec_helper'
require 'devise_last_seen/session'

RSpec.describe DeviseLastSeen::Session, type: :model do
  let(:user) { User.create(email: 'test@example.com', password: 'password123', name: 'Test User') }
  let(:session_duration) { 1.day }

  before do
    Devise.setup do |config|
      config.last_seen_at_enable_session_tracking = true
      config.last_seen_at_session_duration = session_duration
    end
  end

  after do
    Devise.setup do |config|
      config.last_seen_at_enable_session_tracking = false
      config.last_seen_at_session_duration = 1.day
    end
  end

  describe 'associations' do
    it 'belongs to user (polymorphic)' do
      session = described_class.create!(
        user: user,
        started_at: Time.current,
        last_seen_at: Time.current,
        expires_at: Time.current + session_duration
      )

      expect(session.user).to eq(user)
      expect(session.user_type).to eq('User')
      expect(session.user_id).to eq(user.id)
    end
  end

  describe 'validations' do
    it 'requires user_id' do
      session = described_class.new(
        user_type: 'User',
        started_at: Time.current,
        last_seen_at: Time.current,
        expires_at: Time.current + session_duration
      )

      expect(session).not_to be_valid
      expect(session.errors[:user_id]).to be_present
    end

    it 'requires user_type' do
      session = described_class.new(
        user_id: user.id,
        started_at: Time.current,
        last_seen_at: Time.current,
        expires_at: Time.current + session_duration
      )

      expect(session).not_to be_valid
      expect(session.errors[:user_type]).to be_present
    end

    it 'requires last_seen_at' do
      session = described_class.new(
        user: user,
        started_at: Time.current,
        expires_at: Time.current + session_duration
      )

      expect(session).not_to be_valid
      expect(session.errors[:last_seen_at]).to be_present
    end
  end

  describe 'scopes' do
    describe '.last_seen_at' do
      it 'orders by last_seen_at descending' do
        session1 = described_class.create!(
          user: user,
          started_at: 2.hours.ago,
          last_seen_at: 2.hours.ago,
          expires_at: 1.hour.ago
        )

        session2 = described_class.create!(
          user: user,
          started_at: 1.hour.ago,
          last_seen_at: 1.hour.ago,
          expires_at: Time.current
        )

        session3 = described_class.create!(
          user: user,
          started_at: 3.hours.ago,
          last_seen_at: 3.hours.ago,
          expires_at: 2.hours.ago
        )

        results = described_class.last_seen_at
        expect(results.first).to eq(session2)
        expect(results.second).to eq(session1)
        expect(results.third).to eq(session3)
      end
    end

    describe '.active' do
      it 'returns only sessions that have not expired' do
        active_session = described_class.create!(
          user: user,
          started_at: 1.hour.ago,
          last_seen_at: 1.hour.ago,
          expires_at: 1.hour.from_now
        )

        expired_session = described_class.create!(
          user: user,
          started_at: 2.hours.ago,
          last_seen_at: 2.hours.ago,
          expires_at: 1.hour.ago
        )

        active_sessions = described_class.active

        expect(active_sessions).to include(active_session)
        expect(active_sessions).not_to include(expired_session)
      end

      it 'orders by last_seen_at descending' do
        session1 = described_class.create!(
          user: user,
          started_at: 2.hours.ago,
          last_seen_at: 2.hours.ago,
          expires_at: 1.hour.from_now
        )

        session2 = described_class.create!(
          user: user,
          started_at: 1.hour.ago,
          last_seen_at: 1.hour.ago,
          expires_at: 1.hour.from_now
        )

        results = described_class.active
        expect(results.first).to eq(session2)
        expect(results.second).to eq(session1)
      end
    end
  end

  describe '.create_for' do
    context 'when there is no active session' do
      it 'creates a new session' do
        expect do
          described_class.create_for(user)
        end.to change(described_class, :count).by(1)
      end

      it 'sets the correct attributes on the new session' do
        freeze_time = Time.current
        allow(Time).to receive(:current).and_return(freeze_time)

        session = described_class.create_for(user)

        expect(session.user).to eq(user)
        expect(session.started_at).to be_within(1.second).of(freeze_time)
        expect(session.last_seen_at).to be_within(1.second).of(freeze_time + session_duration)
        expect(session.expires_at).to be_within(1.second).of(freeze_time + session_duration)
      end
    end

    context 'when there is an active session' do
      let!(:existing_session) do
        described_class.create!(
          user: user,
          started_at: 1.hour.ago,
          last_seen_at: 1.hour.ago,
          expires_at: 1.hour.from_now
        )
      end

      it 'does not create a new session' do
        expect do
          described_class.create_for(user)
        end.not_to change(described_class, :count)
      end

      it 'updates the existing session last_seen_at' do
        freeze_time = Time.current
        allow(Time).to receive(:current).and_return(freeze_time)

        described_class.create_for(user)

        existing_session.reload
        expect(existing_session.last_seen_at).to be_within(1.second).of(freeze_time)
      end

      it 'does not change other attributes' do
        original_started_at = existing_session.started_at
        original_expires_at = existing_session.expires_at

        described_class.create_for(user)

        existing_session.reload
        expect(existing_session.started_at).to eq(original_started_at)
        expect(existing_session.expires_at).to eq(original_expires_at)
      end
    end

    context 'when there are multiple sessions but only one is active' do
      let!(:active_session) do
        described_class.create!(
          user: user,
          started_at: 1.hour.ago,
          last_seen_at: 1.hour.ago,
          expires_at: 1.hour.from_now
        )
      end

      let!(:expired_session) do
        described_class.create!(
          user: user,
          started_at: 3.hours.ago,
          last_seen_at: 3.hours.ago,
          expires_at: 2.hours.ago
        )
      end

      it 'updates only the active session' do
        freeze_time = Time.current
        allow(Time).to receive(:current).and_return(freeze_time)

        described_class.create_for(user)

        active_session.reload
        expired_session.reload

        expect(active_session.last_seen_at).to be_within(1.second).of(freeze_time)
        expect(expired_session.last_seen_at).to eq(expired_session.last_seen_at)
      end
    end
  end

  describe '.update_current_session' do
    let(:session) do
      described_class.create!(
        user: user,
        started_at: 1.hour.ago,
        last_seen_at: 1.hour.ago,
        expires_at: 1.hour.from_now
      )
    end

    it 'updates the last_seen_at to current time' do
      freeze_time = Time.current
      allow(Time).to receive(:current).and_return(freeze_time)

      described_class.update_current_session(session)

      session.reload
      expect(session.last_seen_at).to be_within(1.second).of(freeze_time)
    end
  end

  describe '.create_new_session' do
    it 'creates a new session with correct attributes' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
      freeze_time = Time.current
      allow(Time).to receive(:current).and_return(freeze_time)

      session = described_class.create_new_session(user)

      expect(session).to be_persisted
      expect(session.user).to eq(user)
      expect(session.started_at).to be_within(1.second).of(freeze_time)
      expect(session.last_seen_at).to be_within(1.second).of(freeze_time + session_duration)
      expect(session.expires_at).to be_within(1.second).of(freeze_time + session_duration)
    end

    context 'when session_duration is nil' do
      before do
        Devise.setup do |config|
          config.last_seen_at_session_duration = nil
        end
      end

      after do
        Devise.setup do |config|
          config.last_seen_at_session_duration = 1.day
        end
      end

      it 'handles nil duration gracefully' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
        freeze_time = Time.current
        allow(Time).to receive(:current).and_return(freeze_time)

        session = described_class.create_new_session(user)

        expect(session).to be_persisted
        expect(session.last_seen_at).to be_within(1.second).of(freeze_time)
        expect(session.expires_at).to be_within(1.second).of(freeze_time)
      end
    end

    context 'with different session durations' do
      let(:session_duration) { 2.hours }

      it 'uses the configured duration' do
        freeze_time = Time.current
        allow(Time).to receive(:current).and_return(freeze_time)

        session = described_class.create_new_session(user)

        expect(session.expires_at).to be_within(1.second).of(freeze_time + 2.hours)
      end
    end
  end
end
