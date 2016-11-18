#! /usr/bin/env rspec

require_relative "profile_test_helper"

test = ProfileTestHelper.new "Head"
test.prepare_schema_dir
test.validate_correct_profiles

context "When checking incorrect profiles," do
  describe "Profile deploy_image.xml" do
    it "complains about wrong deploy_images definition" do
      errors = test.validate_incorrect_profile("deploy_image.xml")
      expect(errors).to match(/"image_installation" missing required attribute "config:type"/)
      expect(errors).to match(/"image_installation".*must be equal to "false" or "true"/)
    end
  end
end
