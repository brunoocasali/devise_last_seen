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
      expect(model.track_last_seen!).to eq(false)
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

  context "non default attribute" do
    subject(:model) { ResourceNonDefaultAttribute.new }
    before { Devise.setup { |c| c.last_seen_at_attribute = :last_seen_at } }
    after { Devise.setup { |c| c.last_seen_at_attribute = :last_seen } }

    describe '#track_last_seen!' do
      it 'calls save disabling validations' do
        expect(model.track_last_seen!).to eq(false)
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
  end
end
