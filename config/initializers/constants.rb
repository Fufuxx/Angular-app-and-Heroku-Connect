Rails.application.config.before_initialize do

  API_VERSION               = ENV["API_VERSION"] || "40.0"
  BULK_API_VERSION          = ENV["BULK_API_VERSION"] || "40.0"

  if Rails.env == 'development'
    CLIENT_ID            = '3MVG9CEn_O3jvv0wPnQVijCLNWtc2UZawJSrEbfc3e6aUhLHM9b_qDYiH8mYg3ZhIF6QybBrpYMsMRinZwaff'
    CLIENT_SECRET        = '1799842286500992884'
  end

  if Rails.env == 'production'
    CLIENT_ID            = '3MVG9zeKbAVObYjPYIZ.RkQ5PHyrUfA0bYKWGVGyBmM2CKP_.38R165vvHSSmHCg9rriK_CvDFqd0XpkuGjDK'
    CLIENT_SECRET        = '4082480976856957840'
  end

end
