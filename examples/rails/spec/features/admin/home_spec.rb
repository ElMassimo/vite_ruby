# frozen_string_literal: true

RSpec.feature 'Admin' do
  before { visit(urls.administrator_path) }

  scenario 'visit admin page' do
    expect(page).to  have_content('Rails Engine')
  end
end
