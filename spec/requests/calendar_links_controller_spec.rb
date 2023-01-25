require "rails_helper"

RSpec.describe "CalendarLinksController", type: :request do
  scenario "user must be logged in to access" do
    SlackUserProfile.create(slack_user_id: "USER")

    get "/calendar_links"

    expect(response).to have_http_status(:unauthorized)
    expect(response.body).to eq("Run /doubleup login in Slack to authenticate")

    User.create!(auth_token: "12345", auth_token_expires_at: 1.minute.from_now, slack_user_id: "USER")
    get "/auth/verify", params: {token: "12345"}

    get "/calendar_links"

    expect(response).to have_http_status(:ok)
  end

  scenario "user creates a calendar link" do
    User.create!(auth_token: "12345", auth_token_expires_at: 1.minute.from_now, slack_user_id: "USER")
    get "/auth/verify", params: {token: "12345"}

    get "/calendar_links/new"
    expect(response).to have_http_status(:ok)

    post "/calendar_links", params: { calendar_link: { link_name: "Test", link_url: "http://example.com/schedule" } }
    expect(response).to redirect_to(calendar_links_path)
    follow_redirect!

    expect(response.body).to include("Calendar link was successfully created")
  end

  scenario "user updates a calendar link" do
    user = User.create!(auth_token: "12345", auth_token_expires_at: 1.minute.from_now, slack_user_id: "USER")
    get "/auth/verify", params: {token: "12345"}

    link = CalendarLink.create(user: user, link_name: "Placeholder", link_url: "https://example.com")
    get "/calendar_links/#{link.id}/edit"
    expect(response).to have_http_status(:ok)

    put "/calendar_links/#{link.id}", params: { calendar_link: { link_name: "Test", link_url: "http://example.com/schedule" } }
    expect(response).to redirect_to(calendar_links_path)
    follow_redirect!

    expect(response.body).to include("Calendar link was successfully updated")
  end

  scenario "user deletes a calendar link" do
    user = User.create!(auth_token: "12345", auth_token_expires_at: 1.minute.from_now, slack_user_id: "USER")
    get "/auth/verify", params: {token: "12345"}

    link = CalendarLink.create(user: user, link_name: "Placeholder", link_url: "https://example.com")
    get "/calendar_links"
    expect(response).to have_http_status(:ok)

    delete "/calendar_links/#{link.id}"
    expect(response).to redirect_to(calendar_links_path)
    follow_redirect!

    expect(response.body).to include("Calendar link was successfully destroyed")
  end
end
