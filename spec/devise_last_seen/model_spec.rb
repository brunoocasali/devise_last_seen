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

    context 'when time passed is lower than 5 minutes' do
      let(:time) { 3.minutes.ago }

      it 'does not change last_seen value' do
        model.last_seen = time
        model.track_last_seen!

        expect(model.last_seen).to eq(time)
      end
    end
  end
end
