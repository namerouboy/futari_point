require 'rails_helper'

RSpec.describe User, type: :model do
  it { is_expected.to have_many(:given_point_cards).class_name('PointCard').dependent(:destroy) }
  it { is_expected.to have_many(:received_point_cards).class_name('PointCard').dependent(:destroy) }
  it { is_expected.to have_many(:point_records).dependent(:destroy) }
  it { is_expected.to have_many(:notifications).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }
end