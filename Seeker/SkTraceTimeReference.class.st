Class {
	#name : #SkTraceTimeReference,
	#superclass : #Object,
	#category : #'Seeker-TraceTime'
}

{ #category : #testing }
SkTraceTimeReference >> referenceThePresentOrLocalFuture: tracer [

	"Answer if the current trace time is in the same traced context as the one denoted by self"

	"For contexts, local future and local pasts are the same as present"

	^ (self referencesThePresent: tracer) or: [ 
		  self referencesTheLocalFuture: tracer ]
]

{ #category : #testing }
SkTraceTimeReference >> referencesTheFuture: tracer [

	"Does this trace time reference the future?"

	^ self subclassResponsibility
]

{ #category : #testing }
SkTraceTimeReference >> referencesTheLocalFuture: tracer [

	"Answer if the current trace time is in the same traced context as the one denoted by self"

	"For contexts, local future and local pasts are the same as present"

	^ self subclassResponsibility
]

{ #category : #testing }
SkTraceTimeReference >> referencesTheLocalPast: tracer [

	"Answer if the current trace time is in the same traced context as the one denoted by self"

	"For contexts, local future and local pasts are the same as present"

	^ self subclassResponsibility
]

{ #category : #testing }
SkTraceTimeReference >> referencesTheLocalPastOrPresent: tracer [

	"Answer if the current trace time is in the same traced context as the one denoted by self"

	"For contexts, local future and local pasts are the same as present"

	^ (self referencesThePresent: tracer) or: [ self referencesTheLocalPast: tracer ]
]

{ #category : #testing }
SkTraceTimeReference >> referencesThePast: tracer [

	"Does this trace time reference the past ?"

	^ self subclassResponsibility
]

{ #category : #testing }
SkTraceTimeReference >> referencesThePastOrPresent: tracer [

	^ (self referencesThePresent: tracer) or: [ self referencesThePast: tracer ]
]

{ #category : #testing }
SkTraceTimeReference >> referencesThePresent: tracer [

	"Does this trace time reference the present?"

	^ self subclassResponsibility
]

{ #category : #testing }
SkTraceTimeReference >> referencesThePresentOrFuture: tracer [

	^ (self referencesThePresent: tracer) or: [ self referencesTheFuture: tracer ]
]