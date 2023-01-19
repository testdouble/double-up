require "rails_helper"

RSpec.describe "LoginController", type: :request do
  scenario "verifies token and redirects" do
    User.create!(auth_token: "12345", auth_token_expires_at: 1.minute.from_now, slack_user_id: "USER")

    get "/auth/verify", params: {token: "12345"}

    expect(response).to redirect_to(recent_matches_path)
  end

  scenario "renders a message when token is not verified" do
    get "/auth/verify", params: {token: "12345"}

    expect(response).to have_http_status(:unauthorized)
    expect(response.body).to eq("Unable to verify")
  end
end
