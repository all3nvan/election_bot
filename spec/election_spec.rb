describe Election do
  describe '#vote' do
    it 'votes for a new candidate' do
      election = Election.new
      voter_id = 1
      candidate_id = 2

      election.vote(voter_id, candidate_id)

      expect(election.instance_variable_get(:@votes)[candidate_id]).to eq(1)
    end

    it 'votes for an existing candidate' do
      election = Election.new
      voter_id = 1
      another_voter_id = 2
      candidate_id = 3

      election.vote(voter_id, candidate_id)
      election.vote(another_voter_id, candidate_id)

      expect(election.instance_variable_get(:@votes)[candidate_id]).to eq(2)
    end

    it 'only allows a voter to vote once' do
      election = Election.new
      voter_id = 1
      candidate_id = 2

      election.vote(voter_id, candidate_id)
      election.vote(voter_id, candidate_id)

      expect(election.instance_variable_get(:@votes)[candidate_id]).to eq(1)
    end
  end

  describe '#winners' do
    it 'returns the candidates with most votes' do
      election = Election.new
      voter_ids = [10, 11, 12, 13, 14]
      candidate_ids = [20, 21, 22]

      election.vote(voter_ids[0], candidate_ids[0])
      election.vote(voter_ids[1], candidate_ids[0])
      election.vote(voter_ids[2], candidate_ids[1])
      election.vote(voter_ids[3], candidate_ids[1])
      election.vote(voter_ids[4], candidate_ids[2])

      expect(election.winners.sort).to eq([candidate_ids[0], candidate_ids[1]].sort)
    end
  end

  describe '#has_voted?' do
    it 'is true if voter has already voted' do
      election = Election.new
      voter_id = 1
      candidate_id = 2

      election.vote(voter_id, candidate_id)

      expect(election.has_voted?(voter_id)).to be true
    end

    it 'is false if voter has not voted' do
      election = Election.new
      voter_id = 1
      candidate_id = 2

      expect(election.has_voted?(voter_id)).to be false
    end
  end
end
