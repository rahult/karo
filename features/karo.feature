Feature: Fetch assets
  In order to get project assets onto a new computer
  I want a one-command way to keep them up to date
  So I don't have to do it myself

  Scenario: Basic UI
    When I get help for "karo"
    Then the exit status should be 0
    And the banner should be present
    And there should be a one line summary of what the app does
    And the banner should document that this app takes options
    And the banner should document that this app's arguments are:
      |from|which is required|
      |to  |which is required|

  Scenario: Happy Path
    Given a path with some files at "/tmp/karo/server_assets/" to be synced at "/tmp/karo/client_assets/"
    When I successfully run `karo /tmp/karo/server_assets/ /tmp/karo/client_assets/`
    Then the assets should be synced out in the directory "/tmp/karo/client_assets/"
