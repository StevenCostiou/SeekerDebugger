Class {
	#name : #SeekerDebuggerPresenter,
	#superclass : #SpPresenter,
	#traits : 'TStDebuggerExtension + TDebuggerUpdateCoordinatorClient',
	#classTraits : 'TStDebuggerExtension classTrait + TDebuggerUpdateCoordinatorClient classTrait',
	#instVars : [
		'seekerDebugger',
		'code',
		'toolbar',
		'stDebugger',
		'currentStepLabel',
		'evaluatorToolbar',
		'evaluatorCode',
		'inspector',
		'valueLabel',
		'evaluatorDebugger',
		'tabs',
		'queriesPresenter',
		'scrollablePresenter'
	],
	#category : #'Seeker-UI'
}

{ #category : #'debugger extension' }
SeekerDebuggerPresenter class >> defaultDisplayOrder [

	^ 1
]

{ #category : #layout }
SeekerDebuggerPresenter class >> defaultLayout [
"Required to work in Pharo 11 for mistery reasons. Not used in Pharo 10 and 9"
	^ SpBoxLayout newVertical
		  add: 'Stepping Control' expand: false;
		  add: #toolbar expand: false;
		  add: #tabs expand: true;
		  add: #currentStepLabel expand: false;
		  yourself
]

{ #category : #'debugger extension' }
SeekerDebuggerPresenter class >> displayOrder [

	^ debuggerExtensionDisplayOrder ifNil: [ 
		  debuggerExtensionDisplayOrder := self defaultDisplayOrder ]
]

{ #category : #'debugger extension' }
SeekerDebuggerPresenter class >> displayOrder: anInteger [
	debuggerExtensionDisplayOrder := anInteger
]

{ #category : #'debugger extension' }
SeekerDebuggerPresenter class >> showInDebugger [
	^showDebuggerExtension ifNil: [showDebuggerExtension := false]
]

{ #category : #'debugger extension' }
SeekerDebuggerPresenter class >> showInDebugger: aBoolean [
	showDebuggerExtension := aBoolean
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> advanceDownHandler [

	self seekerDebugger tracer perform advanceToNextStatement
]

{ #category : #accessing }
SeekerDebuggerPresenter >> blockingDoAndUpdateSessionAfter: aBlock [

	"Updates the UI after executing the block. Forces UI Update, and returns after the UI cycle is completed"

	debuggerUpdateCoordinator blockingDoAndUpdateSessionAfter: aBlock.

]

{ #category : #'debugger extension' }
SeekerDebuggerPresenter >> debuggerExtensionToolName [
	^ 'Seeker'
]

{ #category : #accessing }
SeekerDebuggerPresenter >> debuggerUpdateCoordinator [

	^ debuggerUpdateCoordinator
]

{ #category : #accessing }
SeekerDebuggerPresenter >> debuggerUpdateCoordinator: anObject [

	debuggerUpdateCoordinator := anObject
]

{ #category : #'debugger extension' }
SeekerDebuggerPresenter >> displayOrder [
	^self class displayOrder
]

{ #category : #accessing }
SeekerDebuggerPresenter >> doAndUpdateSessionAfter: aBlock [

	"Updates the UI after executing the block. Forces UI Update in a defered manner
	Returns after executing the block, and before updating the UI.
	See also: blockingDoAndUpdateSessionAfter:.
	"

	debuggerUpdateCoordinator coordinateUpdatesFor: aBlock
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> emergencyStoptHandler [

	"Called when pressing the icon in the toolbar"

	self tracer setEmergencyStopFlag
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> enableTimeTravelingHandler [

	self seekerDebugger tracer isMapped
		ifTrue: [ 
			| context currentTraceTime |
			context := self seekerDebugger tracer currentContext.

			currentTraceTime := context tracedInstructionPC asTraceTimeReference.
			self seekerDebugger tracer doAndUpdateSessionAfter: [ 
				self seekerDebugger tracer timeTravelToTraceTime: currentTraceTime ] ]
		ifFalse: [ self mapExecutionIfNotMappedAlready ]
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> getDefaultCodeText [

	^ '"Put your debugger scripts here...

Example1: a Query with inspectable results
(TTQAllAssignments queryFrom: programStates) asCollection.
 
Example2: Composing a query and showing results in the UI
((TTQAllMessageSends queryFrom: programStates) select: [:state| state methodSelector=#new]) showInSeeker

Workspace variables.

seeker : the main debugger object
programStates : an iterable collection representing the program states.
currentState : an object that is able to read the current state of an execution. Do (SeekerCurrentStateInterface browse) for details.
"'
]

{ #category : #initialization }
SeekerDebuggerPresenter >> initializeCode [

	"comment stating purpose of instance-side method"

	"scope: class-variables  &  instance-variables"

	| codeText |
	code := self newCode.
	code interactionModel: StSindarinContextInteractionModel new.
	code syntaxHighlight: true.
	codeText := SeekerGlobals instance seekerCodePresenterText.
	((codeText isKindOf: String) or: [ codeText isKindOf: Text ])
		ifTrue: [ code text: codeText ]
		ifFalse: [ code text: self getDefaultCodeText , String cr ].
	code whenTextChangedDo: [ self onCodeTextChanged ]
]

{ #category : #initialization }
SeekerDebuggerPresenter >> initializeEvaluatorCode [
   "We define the extensions Code presenter initialization here"
   evaluatorCode := self newCode.
   evaluatorCode interactionModel: EvaluatorDebuggerCodeInteractionModel new.
   evaluatorCode syntaxHighlight: true.
   evaluatorCode text: '"put your expression here"'
]

{ #category : #initialization }
SeekerDebuggerPresenter >> initializeEvaluatorPresenters [
   "Called by the Spec framework. This method describes how the widgets are initialized"
   self initializeEvaluatorToolbar.
   self initializeEvaluatorCode.
    
   valueLabel := self newLabel.
   valueLabel label: 'Write an expression first'.
   inspector := nil inspectionRaw.
   inspector owner: self.
 
   "when changing the selected context in the stDebugger stackTable, re-evaluate the expression in that context"
   evaluatorDebugger stDebugger stackTable selection whenChangedDo: [ 
      self updatePresenter ].
   self updatePresenter
]

{ #category : #initialization }
SeekerDebuggerPresenter >> initializeEvaluatorToolbar [
   evaluatorToolbar := self newToolbar
                 addItem: (self newToolbarButton
                        icon: (self application iconNamed: #smallDoIt);
                        action: [ self updatePresenter ];
                        yourself);
                 yourself
]

{ #category : #'accessing model' }
SeekerDebuggerPresenter >> initializePresenters [

	"Called automatically by the Spec framework. This method describes how the widgets are initialized"

	self initializeToolbar.
	self initializeCode.
	self initializeTabs.
	"progress := self newProgressBar.
	progress
		progress: [ 
		(self seekerDebugger tracer executionProgress / 100.0) asFloat ]
		every: 0.5 seconds."
	currentStepLabel := self newLabel.
	currentStepLabel label: 'Current Step: -'.
	self initializeEvaluatorPresenters.
	self layout: (SpBoxLayout newVertical
			 add: 'Stepping Control' expand: false;
			 add: #toolbar expand: false;
			 add: #tabs expand: true;
			 add: #currentStepLabel expand: false;
			 yourself)
]

{ #category : #'accessing model' }
SeekerDebuggerPresenter >> initializeTabs [

	self initializeToolbar.
	self initializeCode.
	tabs := self newNotebook.
	queriesPresenter := SeekerQueriesPresenter new
		                    owner: self;
		                    tracer: self seekerDebugger tracer;
		                    yourself.
	tabs addPageTitle: 'Query' provider: [ queriesPresenter ].
	tabs addPageTitle: 'Scripting' provider: [ code ]
]

{ #category : #initialization }
SeekerDebuggerPresenter >> initializeToolbar [

	"For icons inspect next line"

	"Smalltalk ui icons"

	"toolbar := SeekerSpToolbarPresenter new
		           beIcons;"

	toolbar := SeekerSpToolbarPresenter new
		           beBoth;
		           add: (self newToolbarButton
				            label: 'Back 1';
				            icon: (self application iconNamed: #glamorousLeft);
				            action: [ self stepBackOneByteCodeHandler ];
				            yourself);
		           add: (self newToolbarButton
				            label: 'Adv. 1';
				            "icon: (self application iconNamed: #glamorousInto);"icon:
					            (self application iconNamed: #glamorousRight);
				            action: [ self stepIntoHandler ];
				            yourself);
		           add: (self newToolbarButton
				            label: 'Adv. Statement';
				            icon: (self application iconNamed: #glamorousDown);
				            action: [ self advanceDownHandler ];
				            yourself);
		           add: (self newToolbarButton
				            label: 'Prev. Statement';
				            icon: (self application iconNamed: #glamorousUp);
				            action: [ self reverseUpHandler ];
				            yourself);
		           add: (self newToolbarButton
				            label: 'Reset';
				            icon: (self application iconNamed: #smallHome);
				            action: [ self restartHandler ];
				            yourself);
		           add: (self newToolbarButton
				            label: 'To End';
				            icon: (self application iconNamed: #glamorousSpawn);
				            action: [ self stepToEndHandler ];
				            yourself);
		          " add: (self newToolbarButton
				            label: 'Next Iteration';
				            icon: (self application iconNamed: #smallUpdate);
				            action: [ self nextIterationHandler ];
				            yourself);"
		           add: (self newToolbarButton
				            label: 'STOP';
				            icon: (self application iconNamed: #stop);
				            action: [ self emergencyStoptHandler ];
				            yourself);
		           "add: (self newToolbarButton
				            label: 'Enable Time Travel';
				            icon: (self application iconNamed: #smallProfile);
				            action: [ self enableTimeTravelingHandler ];
				            yourself);""addItem: (self newToolbarButton
				            label: 'Mark end statement';
				            icon: (self application iconNamed: #protocolPrivate);
				            action: [self setEndHandler ];
				            yourself);"
			           yourself
]

{ #category : #initialization }
SeekerDebuggerPresenter >> insertCodeText: aString [
code text: (code text, aString)
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> mapExecutionIfNotMappedAlready [
"This function also notifies in the UI"
	(self seekerDebugger tracer isMapped) ifTrue:[^self].
	self seekerDebugger tracer quickMap ifTrue:[self inform: 'SEEKER: Time Traveling Enabled'] ifFalse: [ self inform: 'SEEKER: Could not enable Time Traveling' ]
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> nextIterationHandler [

	self seekerDebugger tracer perform stepToNextIteration
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> onCodeTextChanged [
	SeekerGlobals instance seekerCodePresenterText: code text.
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> onResultsFilterSubmitHandler [

	self applyResultFilter.
	self updateDisplayedResults
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> restartHandler [

	"Called when pressing the icon in the toolbar"

	self mapExecutionIfNotMappedAlready.
	self doAndUpdateSessionAfter: [ 
		self seekerDebugger restart ]
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> reverseUpHandler [

	self seekerDebugger tracer perform reverseToPreviousStatement
]

{ #category : #accessing }
SeekerDebuggerPresenter >> seekerDebugger [

	^ seekerDebugger
]

{ #category : #accessing }
SeekerDebuggerPresenter >> seekerDebugger: anObject [

	seekerDebugger := anObject
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> seekerStepUntilSelectedExpressionFails [
^nil
]

{ #category : #initialization }
SeekerDebuggerPresenter >> setCodeText: aString [
code text: aString
]

{ #category : #initialization }
SeekerDebuggerPresenter >> setEndHandler [
seekerDebugger setEndFromCurrentStep
]

{ #category : #'accessing model' }
SeekerDebuggerPresenter >> setModelBeforeInitialization: aStDebugger [

	| setupBlock |
	stDebugger := aStDebugger.
	seekerDebugger := SeekerDebugger newFor: aStDebugger.
	seekerDebugger seekerDebuggerPresenter: self.
	evaluatorDebugger := EvaluatorDebugger new.
	evaluatorDebugger stDebugger: aStDebugger.
	debuggerUpdateCoordinator := seekerDebugger debuggerUpdateCoordinator.
	stDebugger debuggerActionModel tracer: seekerDebugger tracer.
	seekerDebugger stDebugger: aStDebugger.
	SeekerSessionHelpers doCriticalInitialization: [ 
		stDebugger updateStep. " updateStep prevents the need to use the deferred method commented below. 
	The reason for that is that the current debugged process of the stDebugger immediately after initialization is the one of the Exception that opened it.
	After that, it does some magic to go to the actual debugged process/context htat signaled the exception.
	Without the forced update Seeker starts stepping from the exception, which is currently unsupported and ends badly (or doesn't end at all).
   In previous versions, the deferred quickSetup worked because it was actually called after the StDebugger was shown (and everything was in the proper state). 
   That method still works, but the user sees that the debugger opens and do stuff, changing quickly, which is quite confusing."
		setupBlock := [ 
		              seekerDebugger quickSetup.
		              seekerDebugger notifyDebuggerInitialized ].
		SeekerConfig default deferredSetup
			ifTrue: [ 
				[ 
				(Delay forSeconds: 1) wait.
				self flag:
					'in deferred initialization, if a failure occurs, it will not be caught by the CriticalIntialization error handler. It should just open a new debugger (hopefully)'.
				UIManager default defer: setupBlock ] fork ]
			ifFalse: setupBlock ]
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> setSelectedContexAsStartingPointHandler [
"Called when pressing the icon in the toolbar"
	self seekerDebugger setSelectedContextAsStartingPoint: stDebugger selectedContext
]

{ #category : #'UI specific' }
SeekerDebuggerPresenter >> showInResult: aQueryDisplayModel [

	queriesPresenter executeAndShow: aQueryDisplayModel query
]

{ #category : #'UI specific' }
SeekerDebuggerPresenter >> showResult: anObject [

	queriesPresenter showResult: anObject
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> startRecordFromContextHandler [
"Called when pressing the icon in the toolbar"
	self seekerDebugger startRecordFromContext: stDebugger currentContext
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> stepBackIntoHandler [
"Called when pressing the icon in the toolbar"
self mapExecutionIfNotMappedAlready.
self doAndUpdateSessionAfter: [ self seekerDebugger tracer pushNavigationHistory .	self seekerDebugger stepBackInto ]
	
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> stepBackOneByteCodeHandler [

	self mapExecutionIfNotMappedAlready.
	self seekerDebugger tracer stepBackOneBytecode
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> stepBackOverHandler [
"Called when pressing the icon in the toolbar"
self mapExecutionIfNotMappedAlready.
self doAndUpdateSessionAfter: [ self seekerDebugger tracer pushNavigationHistory .	self seekerDebugger stepBackOver ]
     
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> stepIntoHandler [

	"Called when pressing the icon in the toolbar"

	self doAndUpdateSessionAfter: [ "self seekerDebugger tracer pushNavigationHistory." 
		self seekerDebugger tracer stepBytecodeAccountingInstrumentation ]
]

{ #category : #'event handling' }
SeekerDebuggerPresenter >> stepOverHandler [
"Called when pressing the icon in the toolbar"
self mapExecutionIfNotMappedAlready.
self doAndUpdateSessionAfter: [ self seekerDebugger tracer pushNavigationHistory .	self seekerDebugger stepOver ]
	
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> stepToEndHandler [

	self seekerDebugger tracer isMapped ifFalse: [ 
		^ self error:
			  'The execution needs to be mapped to perform this action. Ensure that the code was debugged using a "Debug it with Seeker" option' ].
	self seekerDebugger tracer doAndUpdateSessionAfter: [ 
		self seekerDebugger tracer stepToEnd ]
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> syncWithDebugSession [

	| tracer |
	"true ifTrue: [ ^ self ]."
	tracer := self seekerDebugger tracer.
	(tracer isMapped and: [ 
		 self debuggerUpdateCoordinator preventingUpdates not ]) ifTrue: [ 
		tracer blockingDoAndUpdateSessionAfter: [ 
			| context |
			context := stDebugger interruptedContext.
			tracer currentState node
			~= (context compiledCode sourceNodeForPC: context pc) ifTrue: [ 
				tracer recountExecutedBytecodes ] ] ]
]

{ #category : #accessing }
SeekerDebuggerPresenter >> tracer [

	^ self seekerDebugger tracer
]

{ #category : #'as yet unclassified' }
SeekerDebuggerPresenter >> updateEvaluatorCode [
	evaluatorCode interactionModel context: evaluatorDebugger stDebugger currentContext
]

{ #category : #initialization }
SeekerDebuggerPresenter >> updateExpressionValueDisplayed [
   "Evaluate the expression, in the code presenter, using the appropriate context (the current one of the stDebgger). Then update the ui to show and inspect the obtained value, or a potential exception."
   | expressionBlock expressionResult errorFlag errorMessage shownMessage|
   expressionBlock := [ 
                      evaluatorDebugger
                         evaluateInCurrentContextExpression:
                         evaluatorCode text readStream
                         withRequestor: evaluatorCode interactionModel ].
   errorFlag := false.
   expressionResult := expressionBlock
                          on: Exception
                          do: [ :e | 
                             errorFlag := true.
                             errorMessage := e description.
                             e ].
   "The inspector shows the result object in case of success, or the Exception otherwise"
   inspector model: expressionResult.
"asString could potentially throw an exception. We handle that here, to avoid breaking the debugger."
   shownMessage := [ expressionResult asString ] on: Exception
                          do: [ :e | 
                             errorFlag := true.
                             errorMessage := 'Object>>asString thrown an Exception: ', e description.
                             e ].
   valueLabel label: (errorFlag
          ifTrue: [ errorMessage ]
          ifFalse: [ "expressionResult asString" shownMessage])
]

{ #category : #'accessing model' }
SeekerDebuggerPresenter >> updateLabelOnly [

	currentStepLabel label:
		'ExecutedBytecode: ' , seekerDebugger tracer bytecodeIndex asString
		, ' (' , (self seekerDebugger tracer executionProgress 
			 printShowingDecimalPlaces: 2) , '% of known execution)'
]

{ #category : #'accessing model' }
SeekerDebuggerPresenter >> updatePresenter [

	"Called automatically when the debugger updates its state after stepping""Your widgets should be updated here."

	[ self syncWithDebugSession ] ensure: [ 
		SeekerSessionHelpers doCriticalInitialization: [ 
			code interactionModel context: stDebugger currentContext.
			code interactionModel bindings
				at: #seeker
				put:
				(WorkspaceVariable key: #seeker value: self seekerDebugger tracer).
			code interactionModel bindings
				at: #currentState
				put: (WorkspaceVariable
						 key: #currentState
						 value: self seekerDebugger tracer currentState).
			code interactionModel bindings
				at: #programStates
				put: (WorkspaceVariable
						 key: #programStates
						 value: self seekerDebugger tracer newProgramStates).

			self updateLabelOnly.
			"	self updateEvaluatorCode."
			"		self updateExpressionValueDisplayed."

			super updatePresenter ] ]
]
