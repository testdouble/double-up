require "rails_helper"

RSpec.describe "calendar_links/new" do
  it "shows form for creating a new calendar link" do
    stub_template "calendar_links/_form.html.erb" => "Calendar link form"
    assign(:calendar_link, CalendarLink.new)

    render

    expect(rendered).to match(/New calendar link/)
    expect(rendered).to match(/Back to calendar links/)
    expect(rendered).to match(/href="\/calendar_links"/)
    expect(rendered).to match(/Calendar link form/)
  end
end
