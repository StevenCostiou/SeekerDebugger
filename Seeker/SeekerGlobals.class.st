Class {
	#name : #SeekerGlobals,
	#superclass : #Object,
	#instVars : [
		'seekerCodePresenterText',
		'auxiliaryTempStorage1',
		'auxiliaryTempStorage2',
		'defaultStepperClass',
		'watchedProcesses',
		'ordinatedNodesDictionary',
		'isAltPressed',
		'isShiftPressed',
		'isCommandPressed'
	],
	#classVars : [
		'instance'
	],
	#category : #'Seeker-Helpers'
}

{ #category : #'as yet unclassified' }
SeekerGlobals class >> forceInstanceRefresh [

	instance := nil
]

{ #category : #accessing }
SeekerGlobals class >> instance [
	instance ifNil: [ instance := self new ].
	^instance
]

{ #category : #accessing }
SeekerGlobals >> auxiliaryTempStorage1 [

	^ auxiliaryTempStorage1
]

{ #category : #accessing }
SeekerGlobals >> auxiliaryTempStorage1: anObject [

	auxiliaryTempStorage1 := anObject
]

{ #category : #accessing }
SeekerGlobals >> auxiliaryTempStorage2 [

	^ auxiliaryTempStorage2
]

{ #category : #accessing }
SeekerGlobals >> auxiliaryTempStorage2: anObject [

	auxiliaryTempStorage2 := anObject
]

{ #category : #'as yet unclassified' }
SeekerGlobals >> clearWatchedProcesses [
	watchedProcesses ifNotNil: [watchedProcesses removeAll].
]

{ #category : #'as yet unclassified' }
SeekerGlobals >> debugCommandKeysPressed [

	^ self isCommandPressed and: [ self isShiftPressed ]
]

{ #category : #'as yet unclassified' }
SeekerGlobals >> defaultStepperClass [

	| fallbackDefault |
	fallbackDefault := SkQueryExperimentalTracer.
	defaultStepperClass ifNil: [ defaultStepperClass := fallbackDefault ].
	(defaultStepperClass class inheritsFrom: SkSteppableTracer) 
		ifFalse: [ defaultStepperClass := fallbackDefault ].
	^ defaultStepperClass
]

{ #category : #'as yet unclassified' }
SeekerGlobals >> defaultStepperClass: aStepperClass [
	defaultStepperClass := aStepperClass
]

{ #category : #'as yet unclassified' }
SeekerGlobals >> goToStDebuggerActionModelOverride [

	(StDebugger >> #debuggerActionModel) browse.
	Clipboard clipboardText:
		SeekerStDebuggerDebuggerActionModel name asString.
	self inform:
		'SeekerStDebuggerDebuggerActionModel ready in clipboard for overwriting'
]

{ #category : #accessing }
SeekerGlobals >> isAltPressed [

	^ isAltPressed
]

{ #category : #accessing }
SeekerGlobals >> isAltPressed: anObject [

	isAltPressed := anObject
]

{ #category : #accessing }
SeekerGlobals >> isCommandPressed [

	^ isCommandPressed
]

{ #category : #accessing }
SeekerGlobals >> isCommandPressed: anObject [

	isCommandPressed := anObject
]

{ #category : #accessing }
SeekerGlobals >> isShiftPressed [

	^ isShiftPressed
]

{ #category : #accessing }
SeekerGlobals >> isShiftPressed: anObject [

	isShiftPressed := anObject
]

{ #category : #testing }
SeekerGlobals >> isWatchedProcess: aProcess [
	watchedProcesses ifNil: [ ^false ].
	^watchedProcesses includes: aProcess.
]

{ #category : #accessing }
SeekerGlobals >> seekerCodePresenterText [

	"This returns the remembered text in the scripting code presenter"

	^ seekerCodePresenterText
]

{ #category : #accessing }
SeekerGlobals >> seekerCodePresenterText: anObject [

	seekerCodePresenterText := anObject
]

{ #category : #accessing }
SeekerGlobals >> startQueryingFromBytecodeOne [

	"A configuration flag (read only)"

	"For the test cases, the user might be interested in what happens during the test setup. In that case, this should return true"

	"Bytecoe one is the first bytecode of the context that is restarted each time. If this method returns false, the queries results 
	will include only data corresponding to the executed instructions that take place during and after the call to the test case method"

	^ false
]

{ #category : #'as yet unclassified' }
SeekerGlobals >> stopWatchingProcess: aProcess [

	"Bad solution. It works, but it is only temporary. It is possbile that process will be kept in the collection, so a manual cleaninig is needed"

	watchedProcesses ifNil: [ watchedProcesses := WeakIdentitySet new ].
	(watchedProcesses includes: aProcess)
		ifTrue: [ watchedProcesses remove: aProcess ]
		ifFalse: [ "THIS IS AN ERROR AND SHOULD NEVER BE IN THIS SITUATION"
			self inform: 'SEEKER ERROR: Process not being watched'.
			self error: 'SEEKER ERROR: Process not being watched' ]
]

{ #category : #'as yet unclassified' }
SeekerGlobals >> updateModifierKeys: anEvent [

	anEvent buttons ifNil: [ ^ false ].
	isAltPressed := (anEvent respondsTo: #altKeyPressed)
		                ifTrue: [ anEvent altKeyPressed ]
		                ifFalse: [ false ].
	isShiftPressed := (anEvent respondsTo: #shiftPressed)
		                  ifTrue: [ anEvent shiftPressed ]
		                  ifFalse: [ false ].
	isCommandPressed := (anEvent respondsTo: #commandKeyPressed)
		                    ifTrue: [ anEvent commandKeyPressed ]
		                    ifFalse: [ false ]
]

{ #category : #'as yet unclassified' }
SeekerGlobals >> watchProcess: aProcess [

	"Bad solution. It works, but it is only temporary. It is possbile that process will be kept in the collection, so a manual cleaninig is needed"

	watchedProcesses ifNil: [ watchedProcesses := WeakIdentitySet new ].
	(watchedProcesses includes: aProcess)
		ifFalse: [ watchedProcesses add: aProcess ]
		ifTrue: [ "THIS IS AN ERROR AND SHOULD NEVER BE IN THIS SITUATION"
			self inform: 'SEEKER ERROR: Process already being watched'.
			self error: 'SEEKER ERROR: Process already being watched' ]
]
