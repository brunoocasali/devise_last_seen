require 'integration_spec_helper'

RSpec.describe 'Dummy app', type: :feature do
  include Rack::Test::Methods

  let(:password) { SecureRandom.hex(20) }
  let(:email) { 'abc@abc.com' }
  let(:user) { User.create(email: email, password: password) }

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
end
