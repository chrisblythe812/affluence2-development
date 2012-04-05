require 'spec_helper'

describe Profile do
  it { should have_many :photos }
  it { should have_one :privacy_setting }
  it { should have_one :notification_setting }


  pending "add some examples to (or delete) #{__FILE__}"
end
