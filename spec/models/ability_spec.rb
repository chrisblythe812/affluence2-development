require 'spec_helper'
require "cancan/matchers"

describe "User" do
  describe "authorization : " do
    subject { ability }
    let(:ability){ Ability.new(user) }

    context "member_free" do
       let(:user){ FactoryGirl.build(:user,:member_free) }
       context  "cannot message" do
          it{ should_not be_able_to(:all, :conversation) }
       end
       context  "cannot see photo-stream" do
          it{ should_not be_able_to(:all, :photo_stream) }
       end
      context  "cannot use concierge" do
          it{ should_not be_able_to(:all, :concierge) }
      end
    end

    context "member_free_vetted " do
       let(:user){ FactoryGirl.build(:user,:member_free_vetted) }
      context  "can message" do
        it{ should be_able_to(:all, :conversation) }
      end
      context  "cannot see photo-stream" do
          it{ should_not be_able_to(:all, :photo_stream) }
      end
      context  "cannot use concierge" do
          it{ should_not be_able_to(:all, :concierge) }
      end
    end

    context "member_paid_monthly" do
       let(:user){ FactoryGirl.build(:user,:member_paid_monthly) }
       context  "can message" do
        it{ should be_able_to(:all, :conversation) }
       end
      context  "can see photo-stream" do
          it{ should be_able_to(:all, :photo_stream) }
      end
      context  "can use concierge" do
          it{ should be_able_to(:all, :concierge) }
      end
    end

    context "member_paid_yearly" do
       let(:user){ FactoryGirl.build(:user,:member_paid_yearly) }
       context  "can message" do
        it{ should be_able_to(:all, :conversation) }
       end
      context  "can see photo-stream" do
          it{ should be_able_to(:all, :photo_stream) }
      end
      context  "can use concierge" do
          it{ should be_able_to(:all, :concierge) }
      end
    end

    context "member_paid_monthly_vetted" do
       let(:user){ FactoryGirl.build(:user,:member_paid_monthly_vetted) }
       context  "can message" do
        it{ should be_able_to(:all, :conversation) }
       end
       context  "can see photo-stream" do
          it{ should be_able_to(:all, :photo_stream) }
       end
      context  "can use concierge" do
          it{ should be_able_to(:all, :concierge) }
      end
    end

    context "member_paid_yearly_vetted" do
       let(:user){ FactoryGirl.build(:user,:member_paid_yearly_vetted) }
       context  "can message" do
        it{ should be_able_to(:all, :conversation) }
       end
       context  "can see photo-stream" do
          it{ should be_able_to(:all, :photo_stream) }
       end
      context  "can use concierge" do
          it{ should be_able_to(:all, :concierge) }
      end
    end

  end
end