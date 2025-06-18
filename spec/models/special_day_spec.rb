require 'rails_helper'

RSpec.describe SpecialDay, type: :model do
  it { is_expected.to belong_to(:point_card) }

  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_numericality_of(:multiplier).is_greater_than(1) }
end