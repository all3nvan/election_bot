require 'discordrb'

class ElectionBot::Bot
  def initialize(command_bot)
    @bot = command_bot
    @winner_ids = []
    start_command
    raffle_command
    welcome_winners_await
    @bot.set_user_permission(ENV['BOT_OWNER_ID'].to_i, 2)
  end

  def run
    @bot.run
  end

  private

  def start_command
    @bot.command(:start, election_command_attributes) do |event|
      # TODO: test the if condition
      start_election if election_channel?(event.channel.id)
    end
  end

  def end_command
    @bot.command(:end, election_command_attributes) do |event|
      # TODO: test the if condition
      end_election if election_channel?(event.channel.id)
    end
  end

  def vote_command
    @bot.command(:vote, vote_command_attributes) do |event, candidate_username|
      # TODO: test the if condition
      vote(event.user, candidate_username) if election_channel?(event.channel.id)
    end
  end

  def welcome_winners_await
    @bot.add_await(:welcome_winner, Discordrb::Events::PresenceEvent, { status: :online }) do |event|
      # TODO: extract this and test it
      if @winner_ids.include?(event.user.id)
        @bot.send_message(ENV['CHANNEL_ID'], "Our mayor #{event.user.username} has returned!")
      end
      # AwaitEvents are deleted if their block returns anything other than false,
      # so this is to prevent the await from being deleted
      false
    end
  end

  # TODO: test
  def user_exists?(username)
    @bot
      .users
      .values
      .reject { |user| user == @bot.bot_user }
      .map { |user| user.username.downcase }
      .include?(username.downcase)
  end

  # TODO: test
  def user_id_for(username)
    @bot
      .users
      .find { |_, user| user.username == username }
      .first
  end

  def election_channel?(channel_id)
    # CHANNEL_ID from config file is interpreted as a string
    channel_id == ENV['CHANNEL_ID'].to_i
  end

  def raffle_command
    @bot.command(:raffle, raffle_command_attributes) do
      "You have entered the raffle!"
    end
  end

  def start_election
    @bot.remove_command(:start)
    @election = Election.new
    vote_command
    end_command
    vote_command_attributes[:description]
  end

  def end_election
    @bot.remove_command(:end)
    @bot.remove_command(:vote)
    start_command
    @winner_ids = @election.winners
    update_channel_topic
    announce_winners
  end

  def vote(voter_user, candidate_username)
    if @election.has_voted?(voter_user.id)
      "You have already voted, #{voter_user.username}!"
    elsif voter_user.username == candidate_username
      "You cannot vote for yourself!"
    elsif !user_exists?(candidate_username)
      "#{candidate_username} is not a valid user!"
    else
      @election.vote(voter_user.id, user_id_for(candidate_username))
      "#{voter_user.username} has voted for #{candidate_username}"
    end
  end

  def update_channel_topic
    @bot.channel(ENV['CHANNEL_ID'].to_i).topic = "Mayor(s): #{winner_usernames}"
  end

  def announce_winners
    "Congrats to our mayor(s): #{winner_usernames}"
  end

  def winner_usernames
    @winner_ids
      .map { |id| @bot.users[id].username }
      .join(', ')
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

  def raffle_command_attributes
    {
      help_available: false,
      rate_limit_message: 'STOP SPAMMING ME'
    }
  end
end
