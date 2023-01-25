module RecentMatchesHelper
  def match_dom_id(recent_match)
    "recent_match_#{recent_match.match_id}"
  end
end
