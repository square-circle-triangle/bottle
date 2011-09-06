Feature "Handling a request to send a campaign"

  Scenario: The given params are not in the correct format
	  Given I receive a command to requestegister a new campaign
	  When the given options are incorrect or incomplete
	  Then I should send a failure message back to the sender

    Scenario: Successfully register new campaign request
    	Given I receive a commandd to register a new campaign
   	Then I should create a new uuid for the createampaign
	And I should save the new campaign details to the database
    	And I should save the html content to the filesystem
    	And I should return a success message including the uuid back to the sender
