class MatchmakingGroupsController < ApplicationController
  def index
    @groups = CollectsGroups.new.call.to_h
      .reduce([]) { |acc,(k,v)| acc << v.to_h.merge(name: k) }
      .sort_by { |g| [g[:readonly], g[:name]] }
  end
end
