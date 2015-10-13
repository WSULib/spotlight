require 'spec_helper'

describe 'Metadata Administration', type: :feature do
  let(:exhibit) { FactoryGirl.create(:default_exhibit) }
  let(:exhibit_curator) { FactoryGirl.create(:exhibit_curator, exhibit: exhibit) }
  before { login_as exhibit_curator }

  describe 'edit' do
    it 'displays the metadata edit page' do
      visit spotlight.edit_exhibit_metadata_configuration_path(exhibit)
      expect(page).to have_css('h1 small', text: 'Metadata')
      within("[data-id='language_ssm']") do
        expect(page).to have_css('td', text: 'Language')
      end
    end
  end
end
