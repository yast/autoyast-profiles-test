AutoYaST Profile Validation
===========================

This project contains set of AutoYaST profiles known to be valid and some
others known to be invalid for some known reason. The test should be called
periodically using the latest and greatest AutoYaST schema package from build.

## CAUTION

AutoYaST profiles can contain sensitive information. So check new AutoYaST profiles before adding it to the project. This project is a public project which everyone can see!

## Workflow

- Tests are stored in *test* directory
- Run tests with `rake test:unit` or manually one by one (you have to be root)
- All tests use *ProfileTestHelper* class that initializes a temporary root
  directory using `test/scripts/install_package_from_repos.sh` and installs
  the newest schema from build service
- Repositories are defined in `test/repos_conf.yml` for each target
- Tests can check for validity and also specific invalidity of profiles

## Directory structure

- Correct profiles are stored in *test/$target_name/correct*
- Incorrect profiles in *test/$target_name/incorrect*

## Tests in Details

First of all, you need to initialize the test environment and helper

```ruby
#! /usr/bin/env rspec

require_relative "profile_test_helper"
```

Then you define the target you test, e.g. "Head" (Factory) and install
the AutoYaST schema from repositories belonging to that target.

```ruby
test = ProfileTestHelper.new "Head"
test.prepare_schema_dir
```

All correct tests can be then simply checked this way. The helper method
lists all profiles in *test/Head/correct* directory and validates them one
by one. All errors are reported.

```ruby
test.validate_correct_profiles
```

To check that an incorrect profile reports an error, run, e.g., this

```ruby
it "complains about wrong deploy_images definition" do
  errors = test.validate_incorrect_profile("deploy_image.xml")
  expect(errors).to match(/"image_installation" missing required attribute "config:type"/)
  expect(errors).to match(/"image_installation".*must be equal to "false" or "true"/)
end
```

## Packages Required for Running Test

- rubygem(rspec)
- rubygem(yast-rake)
- rubygem(cheetah)
- jing
- zypper
- rpm
- coreutils

