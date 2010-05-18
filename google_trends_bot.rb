require 'open-uri'
require 'rubygems'
require 'nokogiri'
require 'logger'
require 'oauth'

TWEET_MAX = 140

CONSUMER_KEY = 'AAAA'
CONSUMER_SECRET = 'BBBB'
ACCESS_TOKEN = 'CCCC'
ACCESS_TOKEN_SECRET = 'DDDD'

# ready for OAUTH
consumer = OAuth::Consumer.new(
	CONSUMER_KEY,
	CONSUMER_SECRET,
	:site => 'http://twitter.com/'
)
access_token = OAuth::AccessToken.new(
	consumer,
	ACCESS_TOKEN,
	ACCESS_TOKEN_SECRET
)

######
logfile = File.open("./log/twitter_bot.log", File::WRONLY | File::APPEND)
log = Logger::new(logfile, "monthly")
log.level = Logger::INFO
######

log.info("#### Google trend bot START ####")

uri = "http://www.google.co.jp/trends/hottrends/atom/hourly"

doc = Nokogiri::HTML( open(uri) )

# get a trending key words
key_words_a = doc.search("li").search("span").search("a").map {|elm|
	elm.inner_text
}

# string processing
key_words_s = key_words_a.join(',')
length = key_words_s.split(//u).length

# process more than 140 letters
if length >= TWEET_MAX
	key_words_s = key_words_s.split(//u)[0..TWEET_MAX-1].join('')
end
tweet = key_words_s
log.info(tweet)

# submit a tweet
begin
	response = access_token.post(
		'http://twitter.com/statuses/update.json',
		'status' => tweet
	)
	log.info(response)
rescue => err
	log.fatal("Twitter error")
	log.fatal(err)
end

log.info("#### END ####")
