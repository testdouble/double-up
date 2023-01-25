require "rails_helper"

RSpec.describe "calendar_links/index" do
  it "displays all of the current user's calendar links" do
    user = User.create(slack_user_id: "USER")
    calendly = CalendarLink.create(user: user, link_name: "Calendly for Cases", link_url: "https://calendly.com/sherlock.holmes/solve-my-case")
    alternative = CalendarLink.create(user: user, link_name: "Calendly for Chat", link_url: "https://calendly.com/sherlock.holmes/lets-chat")

    assign(:calendar_links, [calendly, alternative])

    render

    expect(rendered).to match(/Your calendar links/)
    expect(rendered).to match(/New calendar link/)
    expect(rendered).to match(/href="\/calendar_links\/new"/)
    expect(rendered).to match(/Calendly for Cases/)
    expect(rendered).to match(/Calendly for Chat/)
  end
end
