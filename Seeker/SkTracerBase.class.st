"
Current Step Is the last node of the trace (Its included).
When it is about to be executed, it is noted as open, and it is logged as return when exited.

"
Class {
	#name : #SkTracerBase,
	#superclass : #Object,
	#traits : 'TDebuggerUpdateCoordinatorClient',
	#classTraits : 'TDebuggerUpdateCoordinatorClient classTrait',
	#instVars : [
		'seeker',
		'session',
		'isSessionActive',
		'inMouseButtonEventInstrumentationFlag',
		'instrumentedMethods',
		'stepper',
		'restorer',
		'identityEnforcer',
		'components',
		'objectsTracker',
		'systemCallsHandler',
		'headless',
		'programTimestampToLocal',
		'localTimestampToProgram'
	],
	#category : #'Seeker-Components'
}

{ #category : #'as yet unclassified' }
SkTracerBase >> bindComponents [

	components ifNotNil: [ components do: [ :c | c bindComponents ] ]
]

{ #category : #accessing }
SkTracerBase >> blockingDoAndUpdateSessionAfter: aBlock [

	"Updates the UI after executing the block. Forces UI Update, and returns after the UI cycle is completed.
	See also: doAndUpdateSessionAfter: "

	"I am not sure of the portability of this class"
	headless ifTrue: [ ^self ].
	debuggerUpdateCoordinator coordinateUpdatesFor: aBlock.
	UIManager default currentWorld doOneCycleNow
]

{ #category : #testing }
SkTracerBase >> canStep [

	^ stepper canStep
]

{ #category : #accessing }
SkTracerBase >> components [

	^ components
]

{ #category : #accessing }
SkTracerBase >> components: anObject [

	components := anObject
]

{ #category : #'as yet unclassified' }
SkTracerBase >> componentsLateInitialization [

	components ifNotNil: [ components do: [ :c | c lateInitialization ] ]
]

{ #category : #accessing }
SkTracerBase >> doAndUpdateSessionAfter: aBlock [

	"Updates the UI after executing the block. Forces UI Update in a defered manner
	Returns after executing the block, and before updating the UI.
	See also: blockingDoAndUpdateSessionAfter:.
	"

	headless ifTrue: [ ^ aBlock value ].
	debuggerUpdateCoordinator coordinateUpdatesFor: aBlock
]

{ #category : #'as yet unclassified' }
SkTracerBase >> doMouseButtonEventInstrumentedBlockOnce: aBlock [

	| oldVal |
	oldVal := inMouseButtonEventInstrumentationFlag.
	inMouseButtonEventInstrumentationFlag := true.

	aBlock ensure: [ inMouseButtonEventInstrumentationFlag := oldVal ]
]

{ #category : #accessing }
SkTracerBase >> headless [

	^ headless
]

{ #category : #accessing }
SkTracerBase >> headless: anObject [

	headless := anObject
]

{ #category : #accessing }
SkTracerBase >> identityEnforcer [

	^ identityEnforcer
]

{ #category : #accessing }
SkTracerBase >> identityEnforcer: anObject [

	^ identityEnforcer := anObject
]

{ #category : #accessing }
SkTracerBase >> inMouseButtonEventInstrumentationFlag [

	^ inMouseButtonEventInstrumentationFlag
]

{ #category : #accessing }
SkTracerBase >> inMouseButtonEventInstrumentationFlag: anObject [

	^ inMouseButtonEventInstrumentationFlag := anObject
]

{ #category : #initialization }
SkTracerBase >> initialize [

	isSessionActive := false.
	headless := false.
	programTimestampToLocal := Dictionary new "For the moment, this dictionary is directly handled by SeekerExecutor when needed".
	localTimestampToProgram := Dictionary new "For the moment, this dictionary is directly handled by SeekerExecutor when needed".
	SeekerSessionHelpers doCriticalInitialization: [ 
		self initializeInstrumentedMethods.
		self initializeComponents.
		isSessionActive := true.
		inMouseButtonEventInstrumentationFlag := false ]
]

{ #category : #initialization }
SkTracerBase >> initializeComponents [

	components := OrderedCollection new.
	components add:
		(stepper := SystemVersion current major = 9 ifTrue: [ SkClassicStepper newFor: self ]
			            ifFalse: [ 
				            self flag:
					            'This is used experimentally for Pharo 10 and 11. Possibly faster than the other. Not compatible with Pharo 9. '.
				            SkStepper newFor: self ]).
	components add: (restorer := SkSelectiveExecutionRestorer newFor: self). "SkExecutionRestorer"
	components add: (objectsTracker := SkObjectsTracker newFor: self).
	components add: (identityEnforcer := SkIdentityEnforcer newFor: self).
	components add: (systemCallsHandler := SkSystemCallsHandler newFor: self). "SkOmniSystemCallsHandler"

	self bindComponents
]

{ #category : #initialization }
SkTracerBase >> initializeInstrumentedMethods [

	instrumentedMethods := Set new.
	SeekerMetaDebugHelper doBlock: [ 
		self flag: 'During refactoring time, this feature is disabled'.
		^ self ].
	instrumentedMethods addAll:
		((Pragma fullListOfAllNamed: #seekerInstrumentation:) collect: [ :p | 
			 p method ]).
	instrumentedMethods addAll:
		(QuickWrapMethodProxy allSubclasses do: [ :s | 
			 s methodDictionary values ]).
	instrumentedMethods addAll:
		QuickWrapMethodProxy methodDictionary values
]

{ #category : #testing }
SkTracerBase >> isIterating [

^ stepper iteratingFlag
]

{ #category : #'as yet unclassified' }
SkTracerBase >> isSessionActive [

	^ isSessionActive
]

{ #category : #accessing }
SkTracerBase >> localTimestampToProgram [

	^ localTimestampToProgram
]

{ #category : #'as yet unclassified' }
SkTracerBase >> notifySessionEnd [

	isSessionActive := false.
	self seeker notifySessionEnd
]

{ #category : #accessing }
SkTracerBase >> objectsTracker [

	^ objectsTracker
]

{ #category : #accessing }
SkTracerBase >> objectsTracker: anObject [

	objectsTracker := anObject
]

{ #category : #accessing }
SkTracerBase >> programTimestampToLocal [

	^ programTimestampToLocal
]

{ #category : #starting }
SkTracerBase >> restart [

	self restartAtBytecodeOne
]

{ #category : #'as yet unclassified' }
SkTracerBase >> restartRecordFromContext: aContext [
   self subclassResponsibility
	
]

{ #category : #accessing }
SkTracerBase >> restorer [

	^ restorer
]

{ #category : #accessing }
SkTracerBase >> restorer: anObject [

	restorer := anObject
]

{ #category : #accessing }
SkTracerBase >> seeker [

	^ seeker
]

{ #category : #accessing }
SkTracerBase >> seeker: anObject [

	seeker := anObject
]

{ #category : #'as yet unclassified' }
SkTracerBase >> seekerResultsPresenter [

	"Returns the result presenter. Or Nil"

	^ seeker stDebugger seekerDebuggerPresenter 
]

{ #category : #accessing }
SkTracerBase >> session [

	^ session
]

{ #category : #accessing }
SkTracerBase >> session: anObject [

	session := anObject
]

{ #category : #initialization }
SkTracerBase >> setEmergencyStopFlag [

	stepper setEmergencyStopFlag
]

{ #category : #initialization }
SkTracerBase >> setSelectedContextAsStartingPoint: aContext [
	^self subclassResponsibility 
]

{ #category : #'debug - stepping' }
SkTracerBase >> stepBackInto [

	"comment stating purpose of instance-side method"

	"scope: class-variables  &  instance-variables"

	self subclassResponsibility
]

{ #category : #'debug - stepping' }
SkTracerBase >> stepBackOver [

	"comment stating purpose of instance-side method"

	"scope: class-variables  &  instance-variables"

	self subclassResponsibility
]

{ #category : #'debug - stepping' }
SkTracerBase >> stepInto [

	"comment stating purpose of instance-side method"

	"scope: class-variables  &  instance-variables"

	self subclassResponsibility
]

{ #category : #'debug - stepping' }
SkTracerBase >> stepOver [

	"comment stating purpose of instance-side method"

	"scope: class-variables  &  instance-variables"

	self subclassResponsibility
]

{ #category : #accessing }
SkTracerBase >> stepper [

	^ stepper
]

{ #category : #accessing }
SkTracerBase >> stepper: anObject [

	^ stepper := anObject
]

{ #category : #accessing }
SkTracerBase >> systemCallsHandler [

	^ systemCallsHandler
]

{ #category : #accessing }
SkTracerBase >> systemCallsHandler: anObject [

	systemCallsHandler := anObject
]

{ #category : #starting }
SkTracerBase >> timeTravelToUserStart [
	self subclassResponsibility 
]

{ #category : #accessing }
SkTracerBase >> trace [
	"Returns the collection of steps signatures"
	self subclassResponsibility
]

{ #category : #accessing }
SkTracerBase >> tracer [

	^ self
]

{ #category : #'as yet unclassified' }
SkTracerBase >> ui [

	"Returns the result presenter. Or Nil"

	^ seeker stDebugger seekerDebuggerPresenter 
]
