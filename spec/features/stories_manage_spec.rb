require "rails_helper"

RSpec.describe "managing stories", js: true do
  let(:user) { FactoryBot.create(:user) }
  let(:project) { FactoryBot.create(:project) }
  let!(:story) { FactoryBot.create(:story, project: project) }

  before do
    login_as(user, scope: :user)
  end

  it "allows me to add a story" do
    visit project_path(id: project.id)
    click_link "Add a Story"
    fill_in "story[title]", with: "As a user, I want to add stories"
    fill_in "story[description]", with: "This story allows users to add stories."
    click_button "Create"
    expect(Story.count).to eq 2
  end

  it "allows me to clone a story" do
    visit project_path(id: project.id)
    within("#story_#{story.id}") { click_link "Clone" }
    expect(page.find("#story_title").value).to eq story.title
    expect(page.find("#story_description").value).to eq story.description
    click_button "Create"
    expect(Story.count).to eq 2
  end

  it "allows me to edit a story" do
    visit project_path(id: project.id)
    click_link "Edit"
    fill_in "story[title]", with: "As a user, I want to edit stories"
    click_button "Save Changes"
    expect(page).to have_content "Story updated!"
  end

  it "allows me to delete a story", js: true do
    visit project_path(id: project.id)
    accept_confirm do
      click_link "Delete"
    end
    expect(Story.count).to eq 0
  end

  it "does not allow me to bulk delete stories when there are none selected" do
    visit project_path(id: project.id)
    expect(page).to have_selector("#bulk_delete[aria-disabled='true']")
    expect(page).to have_selector("#bulk_delete[disabled]")
  end

  it "allows me to bulk delete stories when one or more stories are selected" do
    visit project_path(id: project.id)

    within("#story_#{story.id}") { check(option: story.id.to_s) }
    expect(page).to have_no_selector("#bulk_delete[aria-disabled='true']")
    expect(page).to have_no_selector("#bulk_delete[disabled]")
    expect(page).to have_button("Bulk Delete (1 Story)")
    click_button("Bulk Delete (1 Story)")
    expect(Story.count).to eq 0
  end

  it "shows a preview of the description while typing" do
    visit project_path(id: project.id)
    click_link "Add a Story"
    fill_in "story[title]", with: "As a user, I want to add stories"

    desc = <<~DESC
      This story allows users to add stories.

          some
          code

    DESC

    fill_in "story[description]", with: desc

    within(".story_preview .content") do
      expect(page).to have_selector("p", text: "This story allows users to add stories.")
      expect(page).to have_selector("pre", text: "some\ncode")
    end

    click_button "Create"

    expect(page).to have_text(project.title)

    story = Story.last
    within("#story_#{story.id}") do
      click_link("Edit")
    end

    expect(page).to have_text("Edit Story")

    within(".story_preview .content") do
      expect(page).to have_selector("p", text: "This story allows users to add stories.")
      expect(page).to have_selector("pre", text: "some\ncode")
    end
  end
end
