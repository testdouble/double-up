require "rails_helper"

RSpec.describe "rendering a calendar link form partial" do
  it "displays a calendar link form for a new calendar link" do
    render partial: "calendar_links/form", locals: {calendar_link: CalendarLink.new}

    expect(rendered).to match(/Link name/)
    expect(rendered).to match(/name="calendar_link\[link_name\]"/)
    expect(rendered).to match(/Link url/)
    expect(rendered).to match(/name="calendar_link\[link_url\]"/)
    expect(rendered).to match(/Create Calendar link/)
  end

  it "displays a calendar link form for editing an existing calendar link" do
    user = User.create(slack_user_id: "USER")
    calendly = CalendarLink.create(user: user, link_name: "Calendly for Cases", link_url: "https://calendly.com/sherlock.holmes/solve-my-case")

    render partial: "calendar_links/form", locals: {calendar_link: calendly}

    expect(rendered).to match(/Link name/)
    expect(rendered).to match(/name="calendar_link\[link_name\]"/)
    expect(rendered).to match(/value="Calendly for Cases"/)
    expect(rendered).to match(/Link url/)
    expect(rendered).to match(/name="calendar_link\[link_url\]"/)
    expect(rendered).to match(/value="https:\/\/calendly.com\/sherlock.holmes\/solve-my-case"/)
    expect(rendered).to match(/Update Calendar link/)
  end
end
