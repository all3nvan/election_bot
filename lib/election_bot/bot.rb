require 'discordrb'

class ElectionBot::Bot
  def initialize(account, password)
    @bot = Discordrb::Commands::CommandBot.new(
      account,
      password,
      '!',
      {},
      true
    )
    @election = Election.new
    vote_command
    raffle_command
  end

  def run
    @bot.run
  end

  def vote_command
    @bot.command(:vote, vote_command_attributes) do |event, username|
      # CHANNEL_ID from config file is interpreted as a string
      if event.channel.id == ENV['CHANNEL_ID'].to_i
        if @election.has_voted?(event.user.id)
          "You have already voted, #{event.user.username}!"
        elsif !user_exists?(username)
          "#{username} is not a valid user!"
        else
          @election.vote(event.user.id, user_id_for(username))
          "#{event.user.username} has voted for #{username}"
        end
      end
    end
  end

  def vote_command_attributes
    {
      description: 'Vote for the mayor (!vote username)',
      min_args: 1,
      max_args: 1
    }
  end

  def user_exists?(username)
    @bot
      .users
      .values
      .reject { |user| user == @bot.bot_user }
      .map { |user| user.username.downcase }
      .include?(username.downcase)
  end

  def user_id_for(username)
    @bot
      .users
      .find { |_, user| user.username == username }
      .first
  end

  def raffle_command
    @bot.command(:raffle, help_available: false) do
      "You have entered the raffle!"
    end
  end
end
