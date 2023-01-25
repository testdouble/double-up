require "rails_helper"

RSpec.describe "rendering a calendar link partial" do
  it "displays a calendar link" do
    user = User.create(slack_user_id: "USER")
    calendly = CalendarLink.create(user: user, link_name: "Calendly for Cases", link_url: "https://calendly.com/sherlock.holmes/solve-my-case")

    render partial: "calendar_links/calendar_link", locals: {calendar_link: calendly}

    expect(rendered).to match(/Calendly for Cases/)
    expect(rendered).to match(/href="https:\/\/calendly.com\/sherlock.holmes\/solve-my-case"/)
    expect(rendered).to match(/change/)
    expect(rendered).to match(/delete/)
  end
end
