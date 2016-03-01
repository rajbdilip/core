Feature: federated
	Background:
		Given using api version "1"

	Scenario: Federate share a file with another server
		Given Using server "REMOTE"
		And user "user1" exists
		And Using server "LOCAL"
		And user "user0" exists
		When User "user0" from server "LOCAL" shares "/textfile0.txt" with user "user1" from server "REMOTE"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And Share fields of last share match with
			| id | A_NUMBER |
			| item_type | file |
			| item_source | A_NUMBER |
			| share_type | 6 |
			| file_source | A_NUMBER |
			| path | /textfile0.txt |
			| permissions | 19 |
			| stime | A_NUMBER |
			| storage | A_NUMBER |
			| mail_send | 0 |
			| uid_owner | user0 |
			| storage_id | home::user0 |
			| file_parent | A_NUMBER |
			| displayname_owner | user0 |
			| share_with | user1@REMOTE |
			| share_with_displayname | user1@REMOTE |

	Scenario: Federate share a file with local server
		Given Using server "LOCAL"
		And user "user0" exists
		And Using server "REMOTE"
		And user "user1" exists
		When User "user1" from server "REMOTE" shares "/textfile0.txt" with user "user0" from server "LOCAL"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And Share fields of last share match with
			| id | A_NUMBER |
			| item_type | file |
			| item_source | A_NUMBER |
			| share_type | 6 |
			| file_source | A_NUMBER |
			| path | /textfile0.txt |
			| permissions | 19 |
			| stime | A_NUMBER |
			| storage | A_NUMBER |
			| mail_send | 0 |
			| uid_owner | user1 |
			| storage_id | home::user1 |
			| file_parent | A_NUMBER |
			| displayname_owner | user1 |
			| share_with | user0@LOCAL |
			| share_with_displayname | user0@LOCAL |

	Scenario: Remote sharee can see the pending share
		Given Using server "REMOTE"
		And user "user1" exists
		And Using server "LOCAL"
		And user "user0" exists
		And User "user0" from server "LOCAL" shares "/textfile0.txt" with user "user1" from server "REMOTE"
		And Using server "REMOTE"
		And As an "user1"
		When sending "GET" to "/apps/files_sharing/api/v1/remote_shares/pending"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And Share fields of last share match with
			| id | A_NUMBER |
			| remote | LOCAL |
			| remote_id | A_NUMBER |
			| share_token | A_TOKEN |
			| name | /textfile0.txt |
			| owner | user0 |
			| user | user1 |
			| mountpoint | {{TemporaryMountPointName#/textfile0.txt}} |
			| accepted | 0 |

	Scenario: accept a pending remote share
		Given Using server "REMOTE"
		And user "user1" exists
		And Using server "LOCAL"
		And user "user0" exists
		And User "user0" from server "LOCAL" shares "/textfile0.txt" with user "user1" from server "REMOTE"
		When User "user1" from server "REMOTE" accepts last pending share
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"

	Scenario: Federate reshare a file
		Given Using server "REMOTE"
		And user "user1" exists
		And Using server "LOCAL"
		And user "user0" exists
		And User "user0" from server "LOCAL" shares "/textfile0.txt" with user "user1" from server "REMOTE"
		And User "user1" from server "REMOTE" accepts last pending share
		And Using server "REMOTE"
		And As an "user1"
		When User "user1" from server "REMOTE" shares "/textfile0 (2).txt" with user "user0" from server "LOCAL"
		Then the OCS status code should be "100"
		And the HTTP status code should be "200"
		And Share fields of last share match with
			| id | A_NUMBER |
			| item_type | file |
			| item_source | A_NUMBER |
			| share_type | 6 |
			| file_source | A_NUMBER |
			| path | /textfile0 (2).txt |
			| permissions | 19 |
			| stime | A_NUMBER |
			| storage | A_NUMBER |
			| mail_send | 0 |
			| uid_owner | user1 |
			| file_parent | A_NUMBER |
			| displayname_owner | user1 |
			| share_with | user0@LOCAL |
			| share_with_displayname | user0@LOCAL |














