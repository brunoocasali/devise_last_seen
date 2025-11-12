require 'spec_helper'
require 'active_model'

class Resource
  extend ::ActiveModel::Callbacks
  include ::ActiveModel::Validations::Callbacks
  extend  ::Devise::Models

  devise :lastseenable

  attr_accessor :last_seen

  def new_record?
    false
  end

  def save(validate: nil)
    validate
  end
end

class ResourceNonDefaultAttribute
  extend ::ActiveModel::Callbacks
  include ::ActiveModel::Validations::Callbacks
  extend  ::Devise::Models

  devise :lastseenable

  attr_accessor :last_seen_at

  def new_record?
    false
  end

  def save(validate: nil)
    validate
  end
end

RSpec.describe 'Devise model extension' do
  subject(:model) { Resource.new }

  describe '#track_last_seen!' do
    it 'calls save disabling validations' do
      expect(model.track_last_seen!).to be(false)
    end

    it 'assigns the current time to last_seen field' do
      model.track_last_seen!

      expect(model.last_seen).to be_within(1.second).of DateTime.now
    end

    context 'when time passed is lower than the interval' do
      let(:time) { (Devise.last_seen_at_interval - 2.minutes).ago }

      it 'does not change last_seen value' do
        model.last_seen = time
        model.track_last_seen!

        expect(model.last_seen).to eq(time)
      end
    end

    context 'when resource class does not have the defined attribute writer' do
      before do
        Devise.setup { |c| c.last_seen_at_attribute = :alfa }
      end

      after do
        Devise.setup { |c| c.last_seen_at_attribute = :last_seen }
      end

      it 'does not change last_seen_at_attribute value' do
        expect do
          model.track_last_seen!
        end.not_to(change { model.try(:alfa) })
      end
    end
  end

  context 'with non default attribute' do
    subject(:model) { ResourceNonDefaultAttribute.new }

    before { Devise.setup { |c| c.last_seen_at_attribute = :last_seen_at } }

    after { Devise.setup { |c| c.last_seen_at_attribute = :last_seen } }

    it 'calls save disabling validations' do
      expect(model.track_last_seen!).to be(false)
    end

    it 'assigns the current time to last_seen field' do
      model.track_last_seen!

      expect(model.last_seen_at).to be_within(1.second).of DateTime.now
    end

    context 'when time passed is lower than the interval' do
      let(:time) { (Devise.last_seen_at_interval - 2.minutes).ago }

      it 'does not change last_seen value' do
        model.last_seen_at = time
        model.track_last_seen!

        expect(model.last_seen_at).to eq(time)
      end
    end
  end

  context 'with session tracking enabled', type: :feature do
    before(:all) do
      require 'integration_spec_helper'
    end

    let(:user) { User.create(email: 'test@example.com', password: 'password123', name: 'Test User') }

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

    describe '#track_last_seen!' do
      context 'when there is no active session' do
        it 'creates a new session' do
          expect do
            user.track_last_seen!
          end.to change(DeviseLastSeen::Session, :count).by(1)
        end

        it 'creates a session with correct attributes' do
          freeze_time = Time.current
          allow(Time).to receive(:current).and_return(freeze_time)

          user.track_last_seen!

          session = DeviseLastSeen::Session.last
          expect(session).to be_present
          expect(session.user).to eq(user)
          expect(session.started_at).to be_within(1.second).of(freeze_time)
        end
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

        it 'does not create a new session' do
          expect do
            user.track_last_seen!
          end.not_to change(DeviseLastSeen::Session, :count)
        end

        it 'updates the existing session last_seen_at' do
          freeze_time = Time.current
          allow(Time).to receive(:current).and_return(freeze_time)

          user.track_last_seen!

          existing_session.reload
          expect(existing_session.last_seen_at).to be_within(1.second).of(freeze_time)
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
            user.track_last_seen!
          end.not_to change(DeviseLastSeen::Session, :count)
        end
      end

      context 'when time passed is lower than the interval' do
        let(:user) do
          User.create(email: 'test@example.com', password: 'password123', name: 'Test User', last_seen: 2.minutes.ago)
        end

        it 'does not create a session' do
          expect do
            user.track_last_seen!
          end.not_to change(DeviseLastSeen::Session, :count)
        end
      end
    end
  end
end
