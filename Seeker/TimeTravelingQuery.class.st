"
Time-Traveling Queries
Are queries that additionally hold their associated display model.
"
Class {
	#name : #TimeTravelingQuery,
	#superclass : #Query,
	#instVars : [
		'displayModel'
	],
	#category : #'Seeker-TimeTravelingQueries'
}

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> checkCompatibilityOfDisplayModelAndProjection [

	<script>
	self displayModel checkColumnsAgainstProjectionClass:
		self projectionFunction.

	self inform: 'All display model columns found in the projection'
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> displayModel [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> performWith: tracer [

	"PerformWith and performWith:withArg: are scripting functions to keep a uniform interface. It is experimental. And you should not probalbly bother using these methods. Use the specific ones instead *queryFrom, showInSeeker, etc"

	tracer ui showInResult: (self queryFrom: tracer newProgramStates) displayModel
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> performWith: tracer withArg: anObject [

	^ self performWith: tracer
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> projectionFields [

	^ self projectionFunction new fields
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> projectionFunction [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> projectionSample [

	^ self projectionFunction new value: AutoTypeDummyObject new
]

{ #category : #'instance creation' }
TimeTravelingQuery class >> queryFrom: aDataSource [

	^ self new
		  fromDataSource: aDataSource;
		  selectionFunction: self selectionFunction new;
		  projectionFunction: self projectionFunction new;
		  yourself
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> runAllChecks [

	<script>
	self superclass ~= TimeTravelingQuery ifTrue: [ 
		(self class methodDictionary includesKey: #projectionFunction) ifTrue: [ (self projectionFunction  == superclass projectionFunction ) ifTrue: [ self error: 'projectionFunction seems to be overriden by an identical one.' ] ] .
		(self class methodDictionary includesKey: #selectionFunction) ifTrue: [ (self selectionFunction   == superclass selectionFunction ) ifTrue: [ self error: 'selectionFunction seems to be overriden by an identical one.' ] ].
		self inform: 'Projection and selection functions apparently correct'].
	self checkCompatibilityOfDisplayModelAndProjection.
	self projectionSample class superclass == AutoTypeBase
		ifFalse: [ 
			self error:
				'Projection is not returning an AutoType object. (Missing a return?)' ]
		ifTrue: [ self inform: 'Projection function returning an AutoType' ].
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> selectionFunction [

	^ self subclassResponsibility
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery class >> showProjectionExample [

	"Select a subclass, check Class Side checkbox in the method categories to see all class side methods, and click this script"

	<script>
	self projectionSample inspect
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery >> displayModel [

	^ displayModel
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery >> displayModel: anObject [

	displayModel := anObject
]

{ #category : #enumerating }
TimeTravelingQuery >> do: aBlock [

	| tracer queryingFlag |
	tracer := self findTracer.
	queryingFlag := tracer stepper haltableMode.
	tracer stepper haltableMode: false.
	[ super do: aBlock ] ensure: [ 
		tracer stepper haltableMode: queryingFlag ]
]

{ #category : #enumerating }
TimeTravelingQuery >> do: aBlock withTimedCallback: timedCallbackBlock every: anIntMilliseconds [

	| tracer queryingFlag |
	tracer := self findTracer.
	queryingFlag := tracer stepper haltableMode.
	tracer stepper haltableMode: false.
	[ 
	super
		do: aBlock
		withTimedCallback: timedCallbackBlock
		every: anIntMilliseconds ] ensure: [ 
		tracer stepper haltableMode: queryingFlag ]
]

{ #category : #execution }
TimeTravelingQuery >> executeAndShowIn: aSeekerTracer [

	"Starts a parallalel process that solves the query, while updating the UI. This method doesn't return the results"

	^ aSeekerTracer executeAndShow: self
]

{ #category : #initialization }
TimeTravelingQuery >> initialize [

	super initialize.
	self ttqInitialize
]

{ #category : #execution }
TimeTravelingQuery >> showInSeeker [

	| tr |
	tr := self findTracer.
	tr ifNil: [ ^ self error: 'Could not detect Seeker Instance' ].
	tr executeAndShow: self
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery >> ttqInitialize [

	displayModel := self class displayModel newForQuery: self.
	displayModel title: self ttqTitle
]

{ #category : #'as yet unclassified' }
TimeTravelingQuery >> ttqTitle [

	"Override this method to show a more specific name"

	^ displayModel title "Uses the default title given by the display model"
]
