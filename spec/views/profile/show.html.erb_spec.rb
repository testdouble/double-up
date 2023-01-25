require "rails_helper"

RSpec.describe "profile/show" do
  it "displays a particular user's profile" do
    user = User.create(slack_user_id: "USER")
    profile = SlackUserProfile.create(slack_user_id: "USER", name: "Sherlock Holmes", avatar_url: "https://example.com/x/512/512")
    CalendarLink.create(user: user, link_name: "Calendly for Cases", link_url: "https://calendly.com/sherlock.holmes/solve-my-case")

    assign(:user, user)
    assign(:user_profile, profile)

    render

    expect(rendered).to match(/Sherlock Holmes/)
    expect(rendered).to match(/src="https:\/\/example.com\/x\/512\/512/)
    expect(rendered).to match(/Calendar Links/)
    expect(rendered).to match(/Calendly for Cases/)
    expect(rendered).to match(/href="https:\/\/calendly.com\/sherlock.holmes\/solve-my-case"/)
  end

  it "displays a particular profile for a user that has never logged in" do
    profile = SlackUserProfile.create(slack_user_id: "USER", name: "Sherlock Holmes", avatar_url: "https://example.com/x/512/512")

    assign(:user, nil)
    assign(:user_profile, profile)

    render

    expect(rendered).to match(/src="https:\/\/example.com\/x\/512\/512/)
    expect(rendered).to match(/Sherlock Holmes hasn't set up a profile yet!/)
  end
end