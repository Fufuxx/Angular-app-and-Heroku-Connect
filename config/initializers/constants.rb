Rails.application.config.before_initialize do

  if Rails.env == 'development'
    SOCKET_URL = 'ws://localhost:3000/cable'
  end

  if Rails.env == 'production'
    SOCKET_URL = 'wss://angular-heroku-connect-tuto.herokuapp.com/cable'
  end
end
