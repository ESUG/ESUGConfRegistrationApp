"
Description
--------------------

I am a personalized table, I render a dictionary in tab format
"
Class {
	#name : #ERDictionaryTable,
	#superclass : #ERTable,
	#category : #'ESUGApp-Component'
}

{ #category : #rendering }
ERDictionaryTable >> renderBody: html [
	html
		tableBody: [ listObject
				do: [ :object | html tableRow: [ 
						headers do: 
							[ :each | html mdlTableCell nonNumerical; with:(object at: each) ] ] ] ]
]

{ #category : #rendering }
ERDictionaryTable >> renderTotalRows: html [
]
