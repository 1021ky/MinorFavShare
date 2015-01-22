require 'twitter'
require 'pp'

class FavShareBot
	#SELF_ID = "FavShareBot"
	SELF_ID = "1021ky"
	MIN_POPULATION = 3
	MAX_POPULATION = 10
	@client = nil

	public

	# ツイートする
	def tweet
		begin
			login_twitter
			loop{
				selected_follower = get_follower_random
				favorite_tweet = get_minor_favorite(selected_follower)
				if favorite_tweet != nil
					p favorite_tweet.text
				end
				sleep 60 * 5
			}
		rescue => ex
			STDERR.puts ex.class.to_s << " raised in " << ex.backtrace[0].to_s
		end
	end

	private

		# フォロワーからランダムに一人を選ぶ
	def get_follower_random
		followers = @client.followers(SELF_ID)
		followers.map.to_set.to_a.sample
	end

	# 指定されたユーザのお気に入りの中でまあまあの人気のものを取得
	def get_minor_favorite(user)
		@client.favorites.shuffle.each{|favorite|
			popularity = favorite.favorite_count
			if popularity >= MIN_POPULATION && popularity <= MAX_POPULATION
				return favorite
			end
		}
	end

	# Twitterにログインする
	def login_twitter
		@client = Twitter::REST::Client.new do |config|
			config.consumer_key    = "dt86qVzDsE8POCzAZdctMeYFp"
			config.consumer_secret = "wi7Blcaljf3ZXYj3ft79eEZ8s0gkfz2POaJlkXD8bVY44p3Pog"
			config.access_token        = "56598769-qmZ8IXkQ4NIEJTRhTQXaLl6TU1TQ5vFJ7kuR5S3e6"
			config.access_token_secret = "HUzlkMJPr6upCEThLqIn5REFt6XaRpyPwayPa9ur0YDec"
		end
	end
end

bot  = FavShareBot.new
bot.tweet
