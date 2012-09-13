OAUTH_SERVICES = YAML.load_file(File.expand_path("#{Rails.root}/config/oauth_services.yml", __FILE__))
Contacts.configure(OAUTH_SERVICES[Rails.env])