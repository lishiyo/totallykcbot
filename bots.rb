require 'twitter_ebooks'
# https://www.twilio.com/blog/2015/02/managing-development-environment-variables-across-multiple-ruby-applications.html
require 'envyable'
Envyable.load('./config/env.yml') # ENV['TWITTER_TOKEN']

# This is an example bot definition with event handlers commented out
# You can define and instantiate as many bots as you like

class MyBot < Ebooks::Bot
  # Configuration here applies to all MyBots
  attr_accessor :original, :model, :model_path

  def configure
    # Consumer details come from registering an app at https://dev.twitter.com/
    # Once you have consumer details, use "ebooks auth" for new access tokens
    self.consumer_key = ENV['TWITTER_CONSUMER_KEY'] # Your app consumer key
    self.consumer_secret = ENV['TWITTER_CONSUMER_SECRET'] # Your app consumer secret

    # Users to block instead of interacting with
    self.blacklist = ['tnietzschequote']

    # Range in seconds to randomize delay when bot.delay is called
    self.delay_range = 1..6
  end

  def on_startup
    load_model!

    scheduler.every '24h' do
      # Tweet something every 24 hours
      # See https://github.com/jmettraux/rufus-scheduler
      # tweet("hi")
      # pictweet("hi", "cuteselfie.jpg")
    end

    scheduler.every '12m' do 
      statement = model.make_statement(140)
      while statement.downcase.include?("buzz")
        statement = model.make_statement(140)
      end
      tweet(statement)
    end
  end

  def on_message(dm)
    # Reply to a DM
    # reply(dm, "secret secrets")
  end

  def on_follow(user)
    # Follow a user back
    follow(user.screen_name)
  end

  def on_mention(tweet)
    # Reply to a mention
    # reply(tweet, "oh hullo")
    reply(tweet, model.make_makestatement(120))
  end

  def on_timeline(tweet)
    # Reply to a tweet in the bot's timeline
    # reply(tweet, "nice tweet")
  end

  def on_favorite(user, tweet)
    # Follow user who just favorited bot's tweet
    follow(user.screen_name)
  end

  def on_retweet(tweet)
    # Follow user who just retweeted bot's tweet
    # follow(tweet.user.screen_name)
  end

  private
  def load_model!
    return if @model

    @model_path ||= "model/#{original}.model" # account to consume
    log "Loading model #{model_path}"
    @model = Ebooks::Model.load(model_path)
  end
end

# Make a MyBot and attach it to the twitterbot handle
MyBot.new(ENV['TWITTERBOT_HANDLE']) do |bot|
  bot.access_token = ENV['TWITTER_TOKEN'] # Token connecting the app to this account
  bot.access_token_secret = ENV['TWITTER_TOKEN_SECRET'] # Secret connecting the app to this account

  # account to consume
  bot.original = ENV['TWITTER_ORIGINAL']
end
