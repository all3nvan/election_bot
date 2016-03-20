describe Election do
  describe '#vote' do
    it 'votes for a new candidate' do
      election = Election.new
      voter_id = 1

      election.vote(voter_id, 'candidate')

      expect(election.instance_variable_get(:@votes)['candidate']).to eq(1)
    end

    it 'votes for an existing candidate' do
      election = Election.new
      voter_id = 1
      another_voter_id = 2

      election.vote(voter_id, 'candidate')
      election.vote(another_voter_id, 'candidate')

      expect(election.instance_variable_get(:@votes)['candidate']).to eq(2)
    end

    it 'only allows a voter to vote once' do
      election = Election.new
      voter_id = 1

      election.vote(voter_id, 'candidate')
      election.vote(voter_id, 'candidate')

      expect(election.instance_variable_get(:@votes)['candidate']).to eq(1)
    end
  end

  describe '#winners' do
    it 'returns the candidates with most votes' do
      election = Election.new
      voter_ids = [10, 11, 12, 13, 14]

      election.vote(voter_ids[0], 'crystal')
      election.vote(voter_ids[1], 'crystal')
      election.vote(voter_ids[2], 'cereal')
      election.vote(voter_ids[3], 'cereal')
      election.vote(voter_ids[4], 'cerealcereal')

      expect(election.winners.sort).to eq(['crystal', 'cereal'].sort)
    end
  end
end
