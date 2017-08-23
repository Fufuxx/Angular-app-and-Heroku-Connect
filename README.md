#Heroku, Heroku Connect and the joy of Production systems

###### What is heroku and heroku connect ?

I like to see Heroku as a super host for your web applications.
You focus on building the app without worrying about the infrastructure behind it, you push it to heroku and you app is ready and accessible on the web. [More infos](https://www.heroku.com/what)

> Heroku is a cloud platform that lets companies build, deliver, monitor and scale apps — we're the fastest way to go from idea to URL, bypassing all those infrastructure headaches.

Heroku connect is an add-on to Heroku. It synchronize any salesforce Org data with your Heroku app postgresql database. So if you create a record in your postgresql Heroku database through your app, Heroku connect will automatically create the record in Salesforce for you and vice-versa. [More infos](https://www.heroku.com/connect)

###### What are we going to do ?

Remember that serie of tutorial on Angular and Ruby on Rails ? Well, we going to use it as a base app to push to Heroku, add on a database to it and set up heroku connect to showcase how this all thing work together. Pretty cool hey ?

Before starting, we gonna need few stuff:

1. The app (last tutorial repro) available [here](https://github.com/Fufuxx/Salesforce-Data-Angular). If you in a mood to go through all the previous tuto first to catch up, it's over [here](https://q-labs.herokuapp.com/2017/05/10/accessing-salesforce-from-your-angular-app/).

2. Few softwares. [Postgres](https://www.postgresql.org/download/) and [Postico](https://eggerapps.at/postico/) (Although Postico is only available for Mac).


###### Start the application

Open up your terminal, go to the folder where you want to application to be and run ``` git clone https://github.com/Fufuxx/Salesforce-Data-Angular.git ```

Then go to the new app directory ``` cd Salesforce-Data-Angular ``` and **Very Important** run ``` git remote rm origin ``` (So you don't end up changing my repro app :p)

From here run ``` bundle install ``` and then ``` rake db:migrate ```. Then run ``` heroku local ``` to start up the app.

Open up an anonymous window and go to ``` localhost:3000 ```. You should be redirected to salesforce login. Log in to one of your SDO et voilà ! You should be in the app. If you click the doStuff button you should see 10 Accounts from your Org (which was the end of the last Angular and Ruby on Rails tuto).
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_01_at_2_19_16_PM-1501593585223.png)

###### Setting up Postgresql instead of SQlite

First, we need the pg gem in order for rails to work with postgresql. So go to your gem file (in root directory). and add this ``` gem 'pg' ``` remove the line ``` gem 'sqlite3' ``` as we won't use sqlite anymore.

Now, go to config/database.yml in your app directory, replace the entire file with this

```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: test-heroku

test:
  <<: *default
  database: test-heroku

production:
  #Set Prod Database here
  <<: *default
  # database:
  # username:
  # password:
  # host:
  # timeout:

```
As you can see, we need a test-heroku database here for our development. Let's set it up on Postico.

Open up Postico and if you do not have localhost set up yet, follow the image informations below.

![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_9_40_32_AM-1503477655438.png)

Once you have done that, simply click connect. On the top menu bar click on localhost. You should see all the Databases there. Click the '+ Database' on the bottom of the app screen and type test-heroku.

![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_9_43_06_AM-1503477808975.png)

Done !

Now let's try the app.
Go to your root directory using terminal and type ```rake db:migrate```
This will run the rails migration for you, creating corresponding tables in the test db.

Then run ```heroku local``` and go to your browser -> ```localhost:3000``` to test the app.

Your app should run normally and click the 'doStuff' should display a list of Accounts

###### Setting up Heroku Connect

Log in to [heroku](www.heroku.com). If you do not have an account, simply create one by registering.

Create a new app
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_9_51_52_AM-1503478354458.png)

Give it a name (should not be already taken)
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_9_52_58_AM-1503478397032.png)

> you are now a proud owner of an Heroku application

Go to Overview on the top menu. We are going to set some add-ons for this app. First will be a Postgresql database and second will be our Heroku Connect.

Click on configure add-ons. Search for Postgres and Heroku connect and add them up (choose free editions, perfect for testing).
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_9_55_20_AM-1503478562720.png)

Now let's configure Heroku connect.
Go back to Overview and click on the Heroku Connect add-on.

Follow the setup process. You will be prompted to log in to salesforce. Use one of your demo org.
This will be the Org that will synch up with Heroku connect. Leave the Schema to salesforce.

Once done, click on Create Mapping. Select Account on the object list and check fields AccountNumber, Name, Industry and BillingCity.

Make sure that you also check the checkboxes on the top
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_11_44_54_AM-1503485125271.png)

This will synch the heroku app database with your Organization data (for Account only as it's the only mapping we have).

###### On the rails side

First, let's set up the Model for Account.
Go to ```app/models``` and create a new file ```account.rb```

Set it up  as follow:
```
class Account < ApplicationRecord
  self.table_name =  'salesforce.account'
end
```

Now let' set up the production database. We need the Database informations and credentials. Go to Overview in you heroku app and click on the Postgres add-on. Then scroll down and click on 'view credentials'.

You should see DB infos as Host, Database, User, Port, Password and so on. We need to set those infos in our database.yml in the rails app.

Go to ```config/database.yml``` and below production set up your database infos found before.

Your ```database.yml``` should look like this:
```
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: test-heroku

test:
  <<: *default
  database: test-heroku

production:
  #Set Prod Database here
  <<: *default
  database: <info on the view credentials>
  username: <info on the view credentials>
  password: <info on the view credentials>
  host: <info on the view credentials>
```

Ok we are now ready to push our app into production and check the synchronization.

###### Pushing app to Heroku

Go back to your Heroku application Overview. Click on 'Settings' tab and scroll down to get the heroku git repro of your app.
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_10_13_00_AM-1503479619348.png)

Copy it.

Then go to your terminal and go to your app directory.
Then type
```
git init
git add .
git commit -m 'DB and heroku connect set up'
git remote add heroku <the github repro address you copied before>
```

If you try ```git remote -v```, you should see your heroku app git repro url with (fetch) and (push).

Ok now type ```git push heroku master```
Once done type ```heroku run rake db:migrate```

Ok now let's see if we can find our Org Account in our heroku Postgres DB.

Type ```heroku run rails c```
Once the command is open type ```Account.count```.

You should see the number of Account present in your Salesforce Org. Accounts have been successfully synchronized to our Heroku Postgres DB.

![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_10_21_22_AM-1503480092852.png)

Ok great ! We have set up Heroku Connect and our Heroku Postgres database. But if you really try the app, you will get an error on login.

This is because we only have a connected app with a callback for localhost:3000. We now need to create one for our production app.

###### Create connected app for Heroku

Go to your Salesforce Org and in setup -> apps
Then scroll down to connected apps and click 'new'

Set your app infos there (replace the heroku app url with yours -> do not forget to set ```/auth/salesforce/callback``` at the end though).
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_10_28_16_AM-1503480528742.png)

And Save. Note the Client Id and Secret from it as we going to need it.

Go back to your Heroku app Overview and click on 'Settings'.

Then click on 'Reveal config var'.
On the bottom of the list, add on your new connected app Client Id (Key is CLIENT_ID and set the value to the connected app Client id) and Secret (Key is CLIENT_SECRET, value also taken from connected app infos) there.
Add one more config var called ```API_VERSION``` and set it up to a value of ```40.0```

Now go back to your terminal window and go to your app root. Then type:
```
git add .
git commit -m 'Auth production Client and Secret set up'
git push heroku master
```

Go for a coffee, letting time for the connected app to settle.

Then test your Heroku application. You should be prompted to allow your connected app to access your infos.
And you should then see your application loading properly.

> Seems to be working fine, but... What if you look into the console ?

![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_11_02_39_AM-1503482568892.png)

You can see that our Websocket is not connecting. This is because, once again it has been configured to work on localhost only.

###### Setting Up Redis Production Websocket

In order for our websocket to work on Heroku, we are going to need a redis server.
So let's go back to our Heroku app Overview, click on configure add-ons, look for Redis and let's add it up.

![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_11_18_28_AM-1503483529364.png)

If you go to Settings and Reveal config vars, you should now see a REDIS_URL Key. Copy the value associated with it.

So to your rails app, in ```config/cable.yml```
Under ```production:``` set the url value to the value you just copied over.

We have now set up Redis. But we still need our cable to use our heroku Url and not localhost:3000.

In ```config/initilaizers``` create a new file called ```constants.rb``` and set it up:
```
Rails.application.config.before_initialize do

  if Rails.env == 'development'
    SOCKET_URL = 'ws://localhost:3000/cable'
  end

  if Rails.env == 'production'
    SOCKET_URL = 'wss://angular-heroku-connect-tuto.herokuapp.com/cable'
  end
end
```
**Of course replace my Heroku app url with yours !**

This will allow us to have a variable SOCKET\_URL that will be set to different value depending if we are in Development mode or in Production.

Finally, let's use it to set our cable properly in Angular.

In ```app/view/index.hmtl/erb``` let's add on the SOCKET_URL to our context (we only add one line to the context variable set up).
```
var context = {
      user: JSON.parse('<%= raw @current_user.id %>'),
      organization: JSON.parse('<%= raw @organization.id %>'),
      instanceUrl: '<%= @organization.instanceurl %>',
      socket_url: '<%= SOCKET_URL %>'
    };
```

Now go to ```public/app/app.component.ts``` and replace:
```
this.App.cable = ActionCable.createConsumer("ws://localhost:3000/cable");
```
By
```
this.App.cable = ActionCable.createConsumer(context.socket_url);
```

So now Angular will get different cable Url depending on the environment you are in -> Dev vs Prod.

Let's commit and push
```
git add .
git commit -m 'Redis and Socket_url set up'
git push heroku master
```

Now try your app again. Websocket should connect properly now :)

> We now have an Angular application running Websocket, on Heroku, using a Postgres Database Synch  to a Salesforce Instance. How about that ?!

###### Displaying Salesforce instance Accounts from Heroku Postgres

Ok to finish off, let's change the Account fetching method to use our postgres DB rather than restforce.

In ```app/channels/my_channel.rb```, Change doStuff like this:
```
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
```

Go to ```public/app/app.component.html``` and simply de-capitalize Name -> change ```{{ a.Name }}``` to ```{{ a.name }}```.

Once again:
```
git add .
git commit -m 'Getting Accounts from Postgres with heroku connect rather than restforce'
git push heroku master
```

Et Voilà ! If you reload your app and click on the doStuff button, you should see the full list of your Synch Salesforce Org.

###### Challenge

How about a little challenge ?
Can you create a new button called 'Create Account' that will create am Account record in Postgres Database ?

To create an Account in ruby:
```
a = Account.new(:name => 'Random')
a.save
```

Once you create the Account, go to your heroku app Overview and click on the Heroku connect add-on. There you can use the Explorer to see if your Account has been created in the Database. You can also see if it has been synch with your Salesforce Instance already.

![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_11_47_07_AM-1503485236983.png)
