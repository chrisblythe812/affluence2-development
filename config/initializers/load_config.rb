EMAIL_CONTENT = YAML.load_file("#{Rails.root}/config/emails.yml")[Rails.env]
