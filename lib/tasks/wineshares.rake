namespace :affluence2 do
  desc "This will create default record in client application table"
  task :create_client => :environment do
     actual_subscriptions = ClientApplication.create(
        :name => 'Vincompass',
        :application_key => '65d880d7de0d89b0b011f48536e67717',
        :secret => 'f0b5009a007a793af924f5f832d377ce')    
  end


end





