#! /usr/bin/env rspec

require_relative "profile_test_helper"

test = ProfileTestHelper.new "sle-12-sp2-s390"
test.prepare_schema_dir
test.validate_correct_profiles
