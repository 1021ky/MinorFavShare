# encoding: utf-8

require 'twitter'
require 'yaml'
require 'singleton'
require 'logger'

LOG_FILE = "../log/FavShareBot.log"#ログ出力先

# フォロワーのそこそこ人気のあるツイートをツイートする
class FavShareBot
	SELF_ID = "MinorFavShare"

	MIN_POPULATION = 3
	MAX_POPULATION = 10
	@client = nil

	@logger = nil

	public
	def initialize
		@logger = Logger.new(File.open(LOG_FILE,'a'), 'daily')
		@logger.info "ini start"
		@client = TwitterAuth.instance.client
		@logger.debug @client.object_id
		@logger.info "ini end"
	end

	# ツイートする
	def tweet
		begin
			selected_follower = get_follower_random
			favorite_tweet = get_minor_favorite(selected_follower)
			if !(favorite_tweet.nil?)
				tweet_text =  @client.user(selected_follower).name + " favorited " + favorite_tweet.uri
				@client.update(tweet_text)
				@logger.debug "tweet text is: " << tweet_text
			end
			sleep 60 * 10
		rescue => ex
			STDERR.puts ex.class.to_s << " raised in " << ex.backtrace[0].to_s
		end
	end

	private

	# フォロワーからランダムに一人を選ぶ
	def get_follower_random
		@logger.debug "pass random"
		followers = @client.followers(SELF_ID)
		selected_follower = followers.map.to_set.to_a.sample(1)
		@logger.debug "selected_follower:" << selected_follower
		return selected_follower
	end

	# 指定されたユーザのお気に入りの中でまあまあの人気のものを取得
	def get_minor_favorite(user)
		@logger.debug "pass get_minor_favorite"
		@client.favorites(user).to_set.each{|favorite|
			popularity = favorite.favorite_count
			if popularity >= MIN_POPULATION && popularity <= MAX_POPULATION
				@logger.debug "minor_favorite:" << favorite << ", popularity:" << popularity
				return favorite
			end
		}
	end

end

# Twitterにアクセスするクライアントを管理するクラス
class TwitterAuth
	include Singleton

	PARAMETER_FILENAME = "../config/development.yaml" # リソースファイル名

	attr_accessor :client #Twitterのクライアント

	@logger = nil

	def initialize
		@logger = Logger.new(File.open(LOG_FILE,'a'), 'daily')

		parameter = load_login_parameter
		login_twitter(parameter)
	end

	# リソースファイルからTwitterにログインするためのパラメータを読み込む
	def load_login_parameter
		parameters = YAML.load_file(PARAMETER_FILENAME)
		@logger.debug "login parameter:" << parameters["twitter"]["consumer_key"]
		@logger.debug "login parameter:" << parameters["twitter"]["consumer_secret"]
		@logger.debug "login parameter:" << parameters["twitter"]["access_token"]
		@logger.debug "login parameter:" << parameters["twitter"]["access_token_secret"]
		return parameters["twitter"]
	end

	# Twitterにログインする
	def login_twitter(parameter)
		@client = Twitter::REST::Client.new do |config|
			config.consumer_key    = parameter["consumer_key"]
			config.consumer_secret = parameter["consumer_secret"]
			config.access_token        = parameter["access_token"]
			config.access_token_secret = parameter["access_token_secret"]
		end
		@logger.debug @client.nil? ? "can¥'t login." : "logined."
	end
end

# ボット用のUtilクラス
class TwitterUtil

	def format_tweet_within_140_text(tweet)

	end
end

# 実行
bot  = FavShareBot.new
bot.tweet
