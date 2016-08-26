# Ensure that people always include a PR summary
warn("Please include a PR summary", sticky: false) if github.pr_body.length < 5

# Ensure that we assign PRs to someone
warn("Please assign someone to your PR", sticky: false) unless github.pr_title.include?("@")

# A warning around making changes to the app, that does not include
# changes to the tests.
has_app_changes = !git.modified_files.grep(/apps/).empty?
has_test_changes = !git.modified_files.grep(/test/).empty?
warn("Tests were not updated", sticky: false) if has_app_changes && !has_test_changes
