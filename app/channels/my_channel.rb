class MyChannel < ApplicationCable::Channel
  def subscribed
    p "Setting Stream"
    stream_from "MyStream"
  end

  def doStuff(data)
    p "Doing stuff"
    begin

    accounts = Account.all

    rescue Exception => e
      ActionCable.server.broadcast "MyStream",
        { :method => 'doStuff', :status => 'error', :message => e.message }
    end
    ActionCable.server.broadcast "MyStream",
      { :method => 'doStuff', :status => 'success', :accounts => accounts }
  end
end
