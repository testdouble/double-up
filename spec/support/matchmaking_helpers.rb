module MatchmakingHelpers
  def new_participants(ids:, historical_matches: [])
    all_match_candidates = ids.map { |id| new_match_candidate(id: id) }

    ids.map { |id|
      new_participant(
        id: id,
        match_candidates: all_match_candidates.reject { |candidate| candidate.id == id },
        historical_matches: historical_matches.select { |match| match.members.include?(id) }
      )
    }
  end

  def new_participant(id:, match_candidates: [], historical_matches: [])
    Matchmaking::Participant.new(
      id: id,
      match_candidates: match_candidates,
      grouped_historical_matches: historical_matches.group_by(&:grouping)
    )
  end

  def new_match_candidate(id:, score: 0)
    Matchmaking::ScoredMatchCandidate.new(id: id, score: score)
  end

  def new_match(grouping:, members:)
    Matchmaking::Match.new(grouping: grouping, members: members)
  end

  def new_candidates_by_score(scored_candidates)
    scored_candidates.reduce([]) { |memo, (score, candidates)|
      memo.concat(candidates.map { |id| new_match_candidate(id: id, score: score) })
    }
  end
end
