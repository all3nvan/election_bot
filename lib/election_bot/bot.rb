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
        elsif !usernames.include?(username)
          "#{username} is not a valid user!"
        else
          @election.vote(event.user.id, username)
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

  def usernames
    @usernames ||= @bot.users.values.reject { |user| user == @bot.bot_user }.map(&:username)
  end
end
