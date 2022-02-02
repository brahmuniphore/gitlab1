@E2eOffline
Feature: Test Offline Audio file - FlightBooking2
  This will test a offline audio wav load end-to-end for FlightBooking2

  @flightBooking2 @Regression
  Scenario Outline: Test offline load of Flight-Booking_2
    ###CREATION OF ORGANIZATION, CATEGORY, AND AGENT
    Given we create an organization called <organization> with description as <description>
    And we create a business process called <category> with colorVR as <colorVR> and description as <description> for <organization>
    Given get keycloak accessToken with username "admin" and password "Welcome@123" and client id "admin-cli" and grant-type "password"
    And we can add keycloak <orgAgentName> with email <agentEmail> as an agent to <organization>
    #
    And we sync <orgAgentName>
    #
    #	###############################################
    #
    #	##SETTING UP CALL VARIABLES
    #
    #Given a "offline-data" request exists
    And a <audio-file> file exists
    And the request organization is <organization>
    And the request category is <category>
    And the request customerId is "8090909099"
    And the request language is <language>
    And the request agentId is <orgAgentName>
    Then generate the callId
    #
    ##############################################
    #
    #And wait for 15 seconds
    #
    #############################################
    #
    ###DEFINITION AND CONFIGURATION` FOR ENTITY AND INTENT
    #
    Then we add language "E" to org <organization> and category <category>
    ##ENTITY
    Then delete all entities
    #
    Then import ai entities from "ConfigAndDefine/flightBooking2/aiEntities/aiEntity.json"
    #
    Then define and configure entities in folder "ConfigAndDefine/flightBooking2/entities/"
    #
    #
    Then validate and configure rules in folder "ConfigAndDefine/flightBooking2/ruleEntity"
    #
    ##SUMMARY FORMAT
    #
    Then post summary format
    #
    ##INTENT
    #
    Then define and configure call categorization with folder "ConfigAndDefine/flightBooking2/call-categorization"
    #
    Then configure alerts in folder "ConfigAndDefine/flightBooking2/alerts"
    #
    ##############################################
    ###TRAINING FOR ENTITY AND INTENT
    Then train entities
    Then train Alerts
    Then submit call category configuration
    Then train call-categories
    Then refresh all caches
    #
    ##############################################
    ###SENDING OFFLINE AUDIO REQUEST
    When the request with file <audio-file> is sent to the audio-connector
    And wait for <audio-file> to get loaded
    #
    #	##############################################
    #
    #	###VERIFYING TRANSCRIPT AGAINST GOLD STANDARD
    #
    Then a transcript is generated for callId
    And the transcript conversation for callId for <turn> has <phrase>
    And the transcript conversation for callId matches the correct version <transcript-file>
    #	##############################################
    #
    #	###VERIFYING ENTITIES AGAINST GOLD STANDARD
    #
    And entities for callId exist
    #And the entity for callId has "Agent Name" as <agentName>
    #
    #	##############################################
    #
    #		###VERIFYING SUMMARY AGAINST GOLD STANDARD
    #
    And a summary for callId exists
    And a summary for callId has intent of <intent>
    And a summary for callId has "Names" <Names>
    And a summary for callId has "Number" <Number>
    And a summary for callId has "Price rule" <Price rule>
    And a summary for callId has "Travel date Rule" <Travel date Rule>
    And a summary for callId has "Location Rule" <Location Rule>
    #
    Then edit "Location Rule" as "London"
    Then submit the edited summaries
    #
    Then compare if "Location Rule" has "London" for callId
    #
    ##############################################
    ###VERIFYING DISPOSITION AGAINST GOLD STANDARD
    And disposition for callId has intent of <intent>
    And we sync <orgAgentName>
    Then edit and submit disposition intent "Departure" as "Arrival"
    Then compare if disposition has changed intent from "Departure" to "Arrival"
    #
    Then verify that supervisor has alert "Call Duration" with type "Information Alert"
    Then verify that supervisor has alert "Coaching alert" with type "Coaching Alert"
    ##############################################
    #
    ###DELETE ENTITIES
    #
    Then delete all entities
    Then delete all alerts

    ##############################################
    ###DELETE ORGANIZATION AND AGENT
    #Then we delete category
    #Then we delete <orgAgentName> who is an <role> from <organization>
    #And we delete an organization called <organization>
    ##############################################
    Examples: 
      | organization | category  | orgAgentName | agentEmail                | role    | language | audio-file                                      | turn | phrase                  | intent                | transcript-file                                           | description   | colorVR       | Names | Number       | Price rule                                                         | Travel date Rule                        | Location Rule |
      | "APITesting" | "flight2" | "APITesting" | "APITesting@uniphore.com" | "Agent" | "E"      | "audio-files/flightBooking2/flightBooking2.wav" |    0 | "thank you for calling" | "Flight_Booking/Book/One Way/Departure" | "src/test/resources/transcript-jsons/flightBooking2.json" | "description" | "colorSample" | "melissa"   | "9737037772" | "500 dollars, 3400 dollars, 468 dollars, 376 dollars and 15 cents, 376 dollars, 369 dollars and 15 cents, 23 dollars" | "8/0/0, 8/19/ , 8/23/ , 8/17/ , 8/24/" | "new jersey, new york, mexico, puerto rico" |

 