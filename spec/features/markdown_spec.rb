require 'rails_helper'

describe Rusrails::Markdown do
  describe '#render' do
    it 'compares input and output for show headers in the active record basics guide' do
      body = File.read("#{Rails.root}/spec/support/fixtures/input_5_1_release_notes.md")
      output = Rusrails::Markdown.new.render(body)

      expect(output).to eq File.read("#{Rails.root}/spec/support/fixtures/output_5_1_release_notes.html")
    end
  end
end
