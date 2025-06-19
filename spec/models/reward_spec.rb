require 'rails_helper'

RSpec.describe Reward, type: :model do
  it { is_expected.to belong_to(:point_card) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_numericality_of(:required_points).is_greater_than(0) }
end