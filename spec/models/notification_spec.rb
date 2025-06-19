require 'rails_helper'

RSpec.describe Notification, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:point_card) }

  it { is_expected.to validate_presence_of(:content) }
end