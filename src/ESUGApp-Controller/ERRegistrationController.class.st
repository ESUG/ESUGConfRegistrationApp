Class {
	#name : #ERRegistrationController,
	#superclass : #ERController,
	#instVars : [
		'attendee'
	],
	#category : #'ESUGApp-Controller'
}

{ #category : #accessing }
ERRegistrationController class >> attendee: anAtteendee [
	|controller|
	controller := self new.
	controller attendee: anAtteendee .
	^ controller 
]

{ #category : #action }
ERRegistrationController >> addAttendeeToTicket: coupon [
	coupon limitStrategyIsLimited
		ifTrue: [ ^ coupon addAttendeeOfTicketLimited: attendee ].
	coupon limitStrategyIsUnlimited
		ifTrue: [ ^ coupon addAttendeeOfTicket: attendee ].
	ERException new
		messageText: 'The ticket does not have a limit strategy allowed.';
		signal
]

{ #category : #action }
ERRegistrationController >> addAttendeeToTicketIfExist [
	[ | coupon |
	coupon := self reductionTicketWithName: attendee coupon.
	self addAttendeeToTicket: coupon ]
		on: ERException
		do: [ attendee coupon: '' ]
]

{ #category : #action }
ERRegistrationController >> addAttendeeToTicketIfExist: anAttendee [
	[| coupon |
	coupon := self reductionTicketWithName: anAttendee coupon.
	self addAttendeeToTicket: coupon.] on: ERException do:[
	anAttendee coupon: ''].

]

{ #category : #accessing }
ERRegistrationController >> attendee [
	^ attendee
]

{ #category : #accessing }
ERRegistrationController >> attendee: anObject [
	attendee := anObject 
]

{ #category : #action }
ERRegistrationController >> convertToGroupManager [
	self attendee userAccount role: (Heap new add: 'groupManager'; yourself )
]

{ #category : #initialize }
ERRegistrationController >> initialize [
	super initialize.
	attendee := ERAttendee new.
]

{ #category : #action }
ERRegistrationController >> save [
	| attendeeResult |
	self validateIfEmailIsAlreadyRegistered: attendee  email.
	attendeeResult := self saveAttendee.
	attendeeResult userAccount isAttendee
		ifTrue: [ self addAttendeeToTicketIfExist: attendeeResult.
			conference addAttendee: attendeeResult ].
	attendeeResult userAccount isGroupManager
		ifTrue: [ (ERGroupManagerController new attendee: attendeeResult)
				groupForGroupManager ].
	conference save.
	^ attendeeResult userAccount
]

{ #category : #action }
ERRegistrationController >> saveAsGroupManager [
	self convertToGroupManager.
	^ self save
]

{ #category : #action }
ERRegistrationController >> saveAttendee [
	| user |
	user := self attendee userAccount save.
	conference addUser: user.
	self attendee userAccount: user.
	^ self attendee save
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validateAdditionalForm [
	
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validateAffiliationForm [
	self validatePatternForRequired: #orgName.
	self validatePatternForRequired: #orgAddrees1.
	self validatePatternForRequired: #orgCity.
	self validateCountry: #orgCountry.
	self validatePatternForRequired: #orgProvince.
	self validatePatternForRequired: #orgPostal.
	self validateSelectValue: #membershipType on: ERAttendee membershipTypes withMessage: 'membership type'.
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validateConferenceForm [
	self validateSelectValue: #gender on: ERAttendee genders withMessage: 'gender'.
	self validateSelectValue: #tshirtSize on: ERAttendee tShirtSizes withMessage: 't-shirt size'.
	self validateSelectValue: #foodPreference on: ERAttendee foodPreferences withMessage: 'food preference'.
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validateContactForm [
	self validatePatternForRequired: #address.
	self validatePatternForRequired: #city.
	self validatePatternForRequired: #province.
	self validatePatternForRequired: #postal.
	self validateCountry: #country.
	attendee facebookURL isEmpty
		ifFalse: [ self validatePatternUrl: #facebookURL ].
	attendee twitterURL isEmpty
		ifFalse: [ self validatePatternUrl: #twitterURL ].
	attendee homePage isEmpty
		ifFalse: [ self validatePatternUrl: #homePage ]
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validateCountry: aSymbol [
	self validatePatternForRequired: aSymbol.
	(attendee perform: aSymbol) = 'Select Country'
		ifTrue: [ ERException new
				messageText: 'Please select a country';
				signal ]
]

{ #category : #action }
ERRegistrationController >> validateIfEmailIsAlreadyRegistered: email [
	conference users
		do: [ :each | 
			each email = email
				ifTrue: [ ERException new
						messageText: 'This email is already registered';
						signal ] ]
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validateIfTicketExist [
	attendee hasCoupon
		ifTrue: [ (self reductionTicketWithName: attendee coupon) isNil
				ifTrue: [ 
					ERException new
						messageText: 'The ticket does not exist for this conference';
						signal ] ]
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validatePatternEmail: aSymbol [
	((attendee perform: aSymbol)
		matchesRegex:
			'\S+@\S+\.\S+')
		ifFalse: [ ERException new
				messageText:
					'The field ' , aSymbol asString , ' does not match with email format.';
				signal ]
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validatePatternForRequired: aSymbol [
	((attendee perform: aSymbol) matchesRegex: '\S+[\S*\s*]*')
		ifFalse: [ ERException new
				messageText:
					'The field ' , aSymbol asString
						, ' is required please add content to it.';
				signal ]
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validatePatternForText: aSymbol [
	((attendee perform: aSymbol) matchesRegex: '[(a-zA-Z)+\s*]{3,}')
		ifFalse: [ ERException new
				messageText: 'The field ' , aSymbol asString , ' only accept a text.';
				signal ]
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validatePatternPassword: aSymbol [
	(((attendee perform: aSymbol)
		matchesRegex: '[A-Za-z0-9._]{8,}')
		and: [ (attendee perform: aSymbol) size >= 8 ])
		ifFalse: [ ERException new
				messageText:
					'The password must have at least 8 characters, and only accepts letters, numbers, slash and dots.';signal ]
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validatePatternUrl: aSymbol [
	"((attendee perform: aSymbol)
		matchesRegex:
			'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_\+.~#?&//=]*)')"
		((attendee perform: aSymbol)
		matchesRegex:
			'\S+')
		ifFalse: [ ERException new
				messageText: 'The field ' , aSymbol text , ' does not match with url format.';
				signal ]
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validatePaymentForm [
	self
		validateSelectValue: #paymentType
		on: ERAttendee paymentTypes
		withMessage: 'payment type'.
	self
		validateSelectValue: #paymentCurrency
		on: ERController currencyAvailable
		withMessage: 'payment currency'.
	self validateIfTicketExist.
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validateRegister [
	self validateUserForm.
	self validateContactForm.
	self validateConferenceForm.
	self validateAffiliationForm.
	self validateAdditionalForm.
	self validatePaymentForm
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validateRegisterForGroupManager [
	self validateUserForm.
	self validateAffiliationForm
]

{ #category : #'as yet unclassified' }
ERRegistrationController >> validateSelectValue: aSymbol on: list withMessage: aString [
	(list includes: (attendee perform: aSymbol))
		ifFalse: [ ERException new
				messageText: 'The ' , aString , ' entered is not valid.';
				signal ]
]

{ #category : #action }
ERRegistrationController >> validateUserForm [
	self validatePatternForRequired: #firstName.
	self validatePatternForText: #firstName.
	self validatePatternForRequired: #lastName.
	self validatePatternForText: #lastName.
	self validatePatternForRequired: #email.
	self validatePatternEmail: #email.
	self
		validateIfEmailIsAlreadyRegistered: attendee email
	"self validatePatternForRequired: #password"
	"self validatePatternPassword: #password"
]

{ #category : #action }
ERRegistrationController >> verifyTicket [
	attendee hasCoupon ifTrue: [  ^ self addAttendeeToTicketIfExist ].
	^ nil
]