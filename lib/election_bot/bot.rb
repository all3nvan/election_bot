require 'discordrb'

class ElectionBot::Bot
  def initialize(command_bot)
    @bot = command_bot
    start_command
    raffle_command
    @bot.set_user_permission(ENV['BOT_OWNER_ID'].to_i, 2)
  end

  def run
    @bot.run
  end

  def start_command
    @bot.command(:start, election_command_attributes) do |event|
      if election_channel?(event.channel.id)
        @bot.remove_command(:start)
        @election = Election.new
        @winner_ids = nil
        vote_command
        end_command
        vote_command_attributes[:description]
      end
    end
  end

  def end_command
    @bot.command(:end, election_command_attributes) do |event|
      if election_channel?(event.channel.id)
        @bot.remove_command(:end)
        @bot.remove_command(:vote)
        start_command
        @winner_ids = @election.winners
      end
    end
  end

  def vote_command
    @bot.command(:vote, vote_command_attributes) do |event, username|
      # CHANNEL_ID from config file is interpreted as a string
      if election_channel?(event.channel.id)
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

  def vote_command_attributes
    {
      description: 'Vote for the mayor (!vote username)',
      min_args: 1,
      max_args: 1
    }
  end

  def election_command_attributes
    {
      help_available: false,
      permission_level: 2
    }
  end

  def election_channel?(channel_id)
    channel_id == ENV['CHANNEL_ID'].to_i
  end

  def raffle_command
    @bot.command(:raffle, help_available: false) do
      "You have entered the raffle!"
    end
  end
end
