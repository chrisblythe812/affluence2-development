require 'spec_helper'

describe Promotion do
  it { should belong_to :promotionable, :polymorphic => true }


  pending "add some examples to (or delete) #{__FILE__}"
end
