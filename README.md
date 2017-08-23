# Heroku, Heroku Connect and the joy of Production systems

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
  database: d4532no0nemblb
  username: vjftcixvfrallo
  password: 155a144734d88979739fe2b909d381173dbf0e7cf5b18d74a2195cbd71fb466e
  host: ec2-54-75-224-100.eu-west-1.compute.amazonaws.com
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

Go back to your Heroku app Overview and click on 'Settings'. Then click on 'Reveal config var'. Add on your new connected app Client Id and Secret there.
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_10_48_23_AM-1503481716274.png)

Add one more config var called ```API_VERSION``` and set it up to a value of ```40.0```

Now go back to your terminal window and go to your app root. Then type:
```
git add .
git commit -m 'Auth production Client and Secret set up'
git push heroku master
```

Go for a coffee, letting time for the connected app to settle.

Then test your Heroku application. You should be prompted to allow your connected app to access your infos.
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_10_51_13_AM-1503481911863.png)

And you should then see your application loading properly.

Well... What if you look into the console ?
![](https://sdotools-q-labs.s3.amazonaws.com/2017/Aug/Screen_Shot_2017_08_23_at_11_02_39_AM-1503482568892.png)

You can see that our Websocket is not connecting. This is because, once again it has been configured to work on localhost only.

###### Setting Up Redis Production Websocket
