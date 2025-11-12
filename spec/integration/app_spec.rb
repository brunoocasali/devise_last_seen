require 'integration_spec_helper'

RSpec.describe 'Dummy app', type: :feature do
  include Rack::Test::Methods

  let(:password) { SecureRandom.hex(20) }
  let(:email) { 'abc@abc.com' }
  let(:name) { 'chuck norris' }
  let(:user) { User.create(email: email, password: password, name: name) }

  def app
    Rails.application
  end

  it 'sets the current time in the column' do
    expect do
      login_as(user)
      get user_session_path
    end.to change(user.reload, :last_seen)
  end

  it 'invokes User#track_last_seen!' do
    allow(user).to receive(:track_last_seen!).and_call_original

    login_as(user)
    get user_session_path

    expect(user).to have_received(:track_last_seen!)
  end

  context 'when user is not in a valid state' do
    let(:user) { User.new(email: email, password: password, name: nil) }

    it 'does not saves the user' do
      expect do
        login_as(user)
        get user_session_path
      end.not_to change(user, :persisted?)
    end
  end

  context 'with different interval configuration' do
    let(:user) { User.create(email: email, password: password, name: name, last_seen: 10.minutes.ago) }

    before do
      Devise.setup { |c| c.last_seen_at_interval = 1.hour }
    end

    after do
      Devise.setup { |c| c.last_seen_at_interval = 5.minutes }
    end

    it 'does not changes the user last_seen_at_attribute' do
      expect do
        login_as(user)
        get user_session_path
      end.not_to change(user.reload, :last_seen)
    end
  end

  context 'when warden is not available' do
    it 'tracks last seen by controller' do
      allow(User).to receive(:find).and_return(user)
      allow(user).to receive(:track_last_seen!).and_call_original

      login_as(user)
      get products_path

      expect(user).to have_received(:track_last_seen!).exactly(2).times
    end
  end

  context 'when devise_last_seen is not activated' do
    let(:admin) { Admin.create(email: email, password: password) }

    it 'does not track last seen' do
      login_as(admin)
      get products_path

      expect(admin.reload.last_seen).to be_nil
    end
  end

  context 'with session tracking enabled' do
    before do
      Devise.setup do |config|
        config.last_seen_at_enable_session_tracking = true
        config.last_seen_at_session_duration = 1.day
      end
    end

    after do
      Devise.setup do |config|
        config.last_seen_at_enable_session_tracking = false
        config.last_seen_at_session_duration = 1.day
      end
    end

    it 'creates a session when tracking last seen' do
      expect do
        login_as(user)
        get user_session_path
      end.to change(DeviseLastSeen::Session, :count).by(1)
    end

    it 'creates a session with correct user' do
      login_as(user)
      get user_session_path

      session = DeviseLastSeen::Session.last
      expect(session.user).to eq(user)
      expect(session.user_type).to eq('User')
    end

    context 'when there is an active session' do
      let!(:existing_session) do
        DeviseLastSeen::Session.create!(
          user: user,
          started_at: 1.hour.ago,
          last_seen_at: 1.hour.ago,
          expires_at: 1.hour.from_now
        )
      end

      it 'updates the existing session instead of creating a new one' do
        expect do
          login_as(user)
          get user_session_path
        end.not_to change(DeviseLastSeen::Session, :count)
      end

      it 'updates the last_seen_at timestamp' do
        original_last_seen = existing_session.last_seen_at

        login_as(user)
        get user_session_path

        existing_session.reload
        expect(existing_session.last_seen_at).to be > original_last_seen
      end
    end

    context 'when session tracking is disabled' do
      before do
        Devise.setup do |config|
          config.last_seen_at_enable_session_tracking = false
        end
      end

      it 'does not create a session' do
        expect do
          login_as(user)
          get user_session_path
        end.not_to change(DeviseLastSeen::Session, :count)
      end
    end
  end
end
