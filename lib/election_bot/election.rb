class Election
  def initialize
    @votes = {}
    @has_voted = Set.new
  end

  def vote(voter, candidate)
    if !@has_voted.include?(voter)
      @votes[candidate] = 0 unless @votes.key?(candidate)
      @votes[candidate] += 1
      @has_voted.add(voter)
    end
  end

  def winners
    most_votes = @votes.values.max
    @votes.select { |_, num_of_votes| num_of_votes == most_votes }.keys
  end
end
