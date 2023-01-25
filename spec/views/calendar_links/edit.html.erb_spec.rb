require "rails_helper"

RSpec.describe "calendar_links/edit" do
  it "shows form for editing an existing calendar link" do
    stub_template "calendar_links/_form.html.erb" => "Calendar link form"
    user = User.create(slack_user_id: "USER")
    calendly = CalendarLink.create(user: user, link_name: "Calendly for Cases", link_url: "https://calendly.com/sherlock.holmes/solve-my-case")
    assign(:calendar_link, calendly)

    render

    expect(rendered).to match(/Editing calendar link/)
    expect(rendered).to match(/Back to calendar links/)
    expect(rendered).to match(/href="\/calendar_links"/)
    expect(rendered).to match(/Calendar link form/)
  end
end