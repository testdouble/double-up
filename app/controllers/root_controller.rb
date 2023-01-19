class RootController < ApplicationController
  def index
    redirect_to recent_matches_path
  end
end
