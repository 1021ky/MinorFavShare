# encoding: utf-8

require 'twitter'
require 'yaml'
# リソースファイルの読み込み
#load '../config/development.rb'

PARAMETER_FILENAME = "../config/development.yaml" # リソースファイル名

class FavShareBot
	SELF_ID = "MinorFavShare"

	MIN_POPULATION = 3
	MAX_POPULATION = 10
	@client = nil

	public

	# ツイートする
	def tweet
		begin
			parameter = load_login_parameter()
			login_twitter(parameter)
			loop{
				selected_follower = get_follower_random
				favorite_tweet = get_minor_favorite(selected_follower)
				if favorite_tweet != nil
					tweet_text =  @client.user(selected_follower).name + " favorited " + favorite_tweet.uri
					@client.update(tweet_text)
				end
				sleep 60 * 10
			}
		rescue => ex
			STDERR.puts ex.class.to_s << " raised in " << ex.backtrace[0].to_s
		end
	end

	private

	# リソースファイルからTwitterにログインするためのパラメータを読み込む
	def load_login_parameter
		parameters = YAML.load_file(PARAMETER_FILENAME)
		return parameters["twitter"]
	end

	# フォロワーからランダムに一人を選ぶ
	def get_follower_random
		followers = @client.followers(SELF_ID)
		followers.map.to_set.to_a.sample(1)
	end

	# 指定されたユーザのお気に入りの中でまあまあの人気のものを取得
	def get_minor_favorite(user)
		@client.favorites(user).to_set.each{|favorite|
			popularity = favorite.favorite_count
			if popularity >= MIN_POPULATION && popularity <= MAX_POPULATION
				return favorite
			end
		}
	end

	# Twitterにログインする
	def login_twitter(parameter)
		@client = Twitter::REST::Client.new do |config|
			config.consumer_key    = parameter["consumer_key"]
			config.consumer_secret = parameter["consumer_secret"]
			config.access_token        = parameter["access_token"]
			config.access_token_secret = parameter["access_token_secret"]
		end
	end
end

class TwitterUtil

	def format_tweet_within_140_text(tweet)

	end
end
bot  = FavShareBot.new
bot.tweet
