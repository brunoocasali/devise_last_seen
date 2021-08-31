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

  context 'with different configuration' do
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
end
