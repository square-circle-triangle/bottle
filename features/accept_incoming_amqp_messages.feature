Feature: Accept incoming AMQP messages

	Scenario: Message is not recognised, or is of an unknown/unregistered type 
		Given I receive a new amqp message
		When that message does not have a registered type
		Then a failure message should be returned to the original sender

	Scenario: Message is not recognised
		Given I receive a new amqp message
		When the message content is corrupt/not recognised
		Then a failure message should be returned to the sender

	Scenario: Successfully receive and process a message
		Given I receive a new amqp message
		And the message type matches a registered message handler
		Then the message should be dispatched to the relevant message handler

