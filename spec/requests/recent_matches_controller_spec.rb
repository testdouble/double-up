require "rails_helper"

RSpec.describe "RecentMatchesController", type: :request do
  scenario "user must be logged in to access" do
    get "/matches"

    expect(response).to have_http_status(:unauthorized)
    expect(response.body).to eq("Run /doubleup login in Slack to authenticate")

    User.create!(auth_token: "12345", auth_token_expires_at: 1.minute.from_now, slack_user_id: "USER")
    get "/auth/verify", params: {token: "12345"}

    get "/matches"

    expect(response).to have_http_status(:ok)
  end
end
