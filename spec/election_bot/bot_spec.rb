require 'spec_helper'

describe ElectionBot::Bot do
  before :each do
    allow(Discordrb::TokenCache).to receive(:new).and_return(nil)
    allow_any_instance_of(Discordrb::Bot).to receive(:login).and_return(nil)
    @command_bot = Discordrb::Commands::CommandBot.new(
      'email',
      'password',
      '!',
      {},
      false
    )
    @election_bot = ElectionBot::Bot.new(@command_bot)
  end

  context 'when bot is initialized' do
    before do
      @commands = @election_bot
        .instance_variable_get(:@bot)
        .instance_variable_get(:@commands)
    end

    it 'has start command' do
      expect(@commands[:start]).to be_an_instance_of(Discordrb::Commands::Command)
    end

    it 'has raffle command' do
      expect(@commands[:raffle]).to be_an_instance_of(Discordrb::Commands::Command)
    end

    # bot has help command by default
    it 'has 3 commands' do
      expect(@commands.size).to eq(3)
    end
  end

  context 'when election is started' do
    before do
      @election_bot.send(:start_election)
      @commands = @election_bot
        .instance_variable_get(:@bot)
        .instance_variable_get(:@commands)
    end

    it 'has a new Election object' do
      expect(@election_bot.instance_variable_get(:@election)).to eq(Election.new)
    end

    it 'has no winner ids' do
      expect(@election_bot.instance_variable_get(:@winner_ids)).to eq([])
    end

    it 'does not have start command' do
      expect(@commands[:start]).to be nil
    end

    it 'has vote command' do
      expect(@commands[:vote]).to be_an_instance_of(Discordrb::Commands::Command)
    end

    it 'has end command' do
      expect(@commands[:end]).to be_an_instance_of(Discordrb::Commands::Command)
    end
  end

  context 'when election is ended' do
    before do
      @election_bot.send(:start_election)
      @expected_winner_ids = [1, 2]
      allow(@election_bot.instance_variable_get(:@election))
        .to receive(:winners)
        .and_return(@expected_winner_ids)
      allow(@election_bot).to receive(:announce_winners).and_return(nil)
      @election_bot.send(:end_election)
      @commands = @election_bot
        .instance_variable_get(:@bot)
        .instance_variable_get(:@commands)
    end

    it 'does not have end command' do
      expect(@commands[:end]).to be nil
    end

    it 'does not have vote command' do
      expect(@commands[:vote]).to be nil
    end

    it 'has start command' do
      expect(@commands[:start]).to be_an_instance_of(Discordrb::Commands::Command)
    end

    it 'has the winner ids' do
      expect(@election_bot.instance_variable_get(:@winner_ids)).to eq(@expected_winner_ids)
    end
  end

  describe '#vote' do
    before do
      @election_bot.send(:start_election)
      @election = @election_bot.instance_variable_get(:@election)
      @voter_user = Discordrb::User.new({ id: 1, username: 'all3nvan' }, nil)
      # candidate username and id are not encapsulated in a User object since a voter votes
      # with just a candidate username. it is then up to the bot to retrieve the candidate id
      @candidate_username = 'cerealcereal'
      @candidate_id = 2
      allow(@election_bot)
        .to receive(:user_id_for)
        .with(@candidate_username)
        .and_return(@candidate_id)
    end

    context 'when user who has not voted casts vote for valid user' do
      it 'casts a vote' do
        allow(@election).to receive(:has_voted?).with(@voter_user.id).and_return(false)
        allow(@election_bot).to receive(:user_exists?).with(@candidate_username).and_return(true)
        expect(@election).to receive(:vote).with(@voter_user.id, @candidate_id)
        @election_bot.send(:vote, @voter_user, @candidate_username)
      end
    end

    context 'when user tries to cast a second vote' do
      it 'does not cast a vote' do
        allow(@election).to receive(:has_voted?).with(@voter_user.id).and_return(true)
        allow(@election_bot).to receive(:user_exists?).with(@candidate_username).and_return(true)
        expect(@election).to_not receive(:vote)
        @election_bot.send(:vote, @voter_user, @candidate_username)
      end
    end

    context 'when user casts a vote for invalid user' do
      it 'does not cast a vote' do
        allow(@election).to receive(:has_voted?).with(@voter_user.id).and_return(false)
        allow(@election_bot).to receive(:user_exists?).with(@candidate_username).and_return(false)
        expect(@election).to_not receive(:vote)
        @election_bot.send(:vote, @voter_user, @candidate_username)
      end
    end
  end
end
