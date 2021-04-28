Class {
	#name : #TracerVariableChanges,
	#superclass : #DSStatementTracer,
	#instVars : [
		'trackedVariableName',
		'trackedVariableValues',
		'navigationHistory',
		'navigationForward',
		'blocksCollection'
	],
	#category : #'Seeker-Components'
}

{ #category : #stackAccessHelpers }
TracerVariableChanges >> astReadAssignmentNewValue [
"Returns the value about to be assigned for the current ast node, if the current node is an assignment node. Otherwise, returns nil"
|node context|
node := self currentNode.
	node isAssignment
		ifFalse: [ ^ nil	"Error signal: 'Not about to perform a assignment'" ].
			context := self currentContext.
	^ context at: context basicSize
]

{ #category : #stackAccessHelpers }
TracerVariableChanges >> astReadAssignmentOldValue [
^self currentNode variable variable readInContext: (self currentContext)
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> autoMapFromStartingPoint [
"Starting point needs to be set first!"
	|currentStep|
	currentStep := self currentIndexlessStepDescriptor.
	self restartAndStepToCondition: [ self currentStepDescriptor hasSamePathAs: currentStep ]
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> autoSetupForTest [
"If a debugger is opened automatically in a failing test, this method helps to map the execution by automatically detect the starting and ending point for the recording."
	|testInitialContext|
	testInitialContext := self findContextInStack: [:aContext| aContext methodSelector = #runCase ].
	testInitialContext ifNil:[^self error: 'Could not detect the initial context for the test.'].
	startingContextForRecord := testInitialContext.
	self restartTestAndStopAtCurrentStep.
	self setEndFromCurrentStep.
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> autoSetupForTestForUnhandledException [
"If a debugger is opened automatically in a failing test, this method helps to map the execution by automatically detect the starting and ending point for the recording." "This handles a debugger oppened by an unhandled exception within a test"
	|testInitialContext|
	testInitialContext := self findContextInStack: [:aContext| aContext methodSelector = #runCase ].
	testInitialContext ifNil:[^self error: 'Could not detect the initial context for the test.'].
	startingContextForRecord := testInitialContext.
	self restartTestAndStopAtCurrentStepForUnhandledExceptionCase.
	self setEndFromCurrentStep.
]

{ #category : #accessing }
TracerVariableChanges >> blocksCollection [

	^ blocksCollection
]

{ #category : #accessing }
TracerVariableChanges >> blocksCollection: anObject [

	blocksCollection := anObject
]

{ #category : #accessing }
TracerVariableChanges >> currentStepDescriptor [ 
	|stepDescriptor containerBlockNode|
	stepDescriptor := super currentStepDescriptor.
	"Check II: Executing code inside blocks"
	containerBlockNode := SkObjectHelpers getBlockNodeOfStatementNode: self currentStatementNode .
containerBlockNode ifNotNil: [ 
	
		 (blocksCollection containsBlock: containerBlockNode) ifTrue: [ 
		| blockLabel |
		blockLabel := blocksCollection createLabelForBlock: containerBlockNode.
		stepDescriptor topStatementID sequenceStaticID belongsToBlock: true.
		stepDescriptor topStatementID sequenceStaticID ownerBlockLabel: blockLabel
		"Must store this info for the stepdescriptor somehow. Maybe just do this when creating the descriptor"
		 ].
 ].
^stepDescriptor
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> doAstStepPostProcess [

	| node |
	node := self currentNode.
	node isAssignment ifTrue: [ 
		| variableName |
		variableName := node variable name.
		variableName = trackedVariableName ifTrue: [ 
			|oldValue newValue actualCurrentStepIndex|
			actualCurrentStepIndex := currentStepIndex +1 "This correction is needed at the moment, because the stepIndex is updated after stepping the ast".
			oldValue := self astReadAssignmentOldValue.
			newValue := self astReadAssignmentNewValue.
			 trackedVariableValues at: actualCurrentStepIndex put: { oldValue . newValue }
			 ] ].
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> doAstStepPreProcess [
|containerBlockNode|
"Check I: Blocks definition"
	self currentNode class = RBBlockNode ifTrue: [ 
		| blockNode |
		blockNode := self currentNode.
		"Need to check if it has already been added. The reason for this is that the ast may step more than once in the same block node"
		(blocksCollection containsBlock: blockNode) ifFalse: [ 
			blocksCollection
				addBlock: blockNode
				toStepIndex: currentStepIndex ] ].
		"Check II: Executing code inside blocks"
	"containerBlockNode := SkObjectHelpers getBlockNodeOfStatementNode: self currentStatementNode .
containerBlockNode ifNotNil: [ 
	
		 (blocksCollection containsBlock: containerBlockNode) ifTrue: [ 
		| blockLabel blockStepDescriptor |
		blockLabel := blocksCollection createLabelForBlock: containerBlockNode.
		""Must store this info for the stepdescriptor somehow. Maybe just do this when creating the descriptor""
		 ].
 ]."
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> doStepClosingProcess [
	^self
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> doStepOpeningProcess [
"We are standing in the statement(current) after the execution of a statement (previous). The current statement hasn't been executed yet. And it is in the execution record at the top (last)"
"
Transcript clear.
self isCurrentStepAssignment ifTrue:[|index|
	Transcript show: 'this is an assignment'. Transcript cr.
	index := self indexOfAssignmentStatementOpeningStepFor: self currentStepDescriptor.
	Transcript show: 'Found opening index: ', index asString. Transcript cr.
	].

	Transcript show: self trace asString.
	Transcript cr."
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> findContextInStack: aBlock [
"returns the first context where the given predicate returns true. Or nil. The stack is traversed from top to bottom. The starting context is the interruptedContext"
^self findContextInStack: aBlock startingContext: self currentContext 
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> findContextInStack: aBlock startingContext: aContext [
"returns the first context where the given predicate returns true. Or nil. The stack is traversed from top to bottom."

aContext ifNil: [ ^nil ].
(aBlock value: aContext) ifTrue: [ ^aContext ].
^self findContextInStack: aBlock startingContext: aContext sender.
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> findStepIndexOfFirstStatementInSameSequenceOfStep: aNumber [
|step|
(aNumber <= 0) ifTrue: [ ^0 ].
(aNumber > trace size) ifTrue: [ ^0 ].
step := trace at: aNumber.
((step topStatementID indexInSequence) = 1) ifTrue: [ ^aNumber ].
"This could be implemented recursivelly, but there is a potential problem. If a step does not have indexInSequence as 1 even if it is the first, the search will continue and an erroneous step will be returned"
^self reverseFindStep: [ :eachStep| (step isSiblingOf: eachStep) and: [eachStep topStatementID indexInSequence = 1]] startingIndex: (aNumber - 1)

	
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> findStepIndexOfLastStepOfTest [
|targetContext|
targetContext := self findContextInStack: [ :aContext| aContext sender methodSelector = #performTest  ] 
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> findStepsWhereMethodSelectorIs: aSymbol [
^ trace select: [ :eachStepDescriptor| eachStepDescriptor methodSelector = aSymbol ].
	
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> findStepsWhereMethodSelectorIs: aSymbol ofClass: aClass [
^ trace select: [ :eachStepDescriptor| (eachStepDescriptor methodSelector = aSymbol) and:[eachStepDescriptor receiverClass = aClass] ].
	
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> findTestContext [
"returns the first context where the given predicate returns true. Or nil. The stack is traversed from top to bottom. The starting context is the interruptedContext"
|isTestContext|
isTestContext := [:aContext| SkObjectHelpers isObject: aContext receiver subclassOf: TestCase ].
^self findContextInStack: isTestContext startingContext: self currentContext 
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> getNewValueForStep: aNumber [
^self
	
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> getOldValueForStep: aNumber [
^self
	
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> getTraceAsStringWithBlocksAliases [
| str |
	str := Character cr join: (trace collect: [ :eachStepDescriptor | 
		|stepIndex|
		
		eachStepDescriptor asString ]).
	"self isUnwinding isNotNil and: [ 
		self isUnwinding ifTrue: [ str := str , '+u' ] ]."
	^ str
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> goBackToTheBeginningOfDeepestStepWithinMethodWithSelector: aSymbol [
	|stepsWithTheMethod lastStepIndex deepestStep deepestStepDepth firstStatementIndex| 
	stepsWithTheMethod := self findStepsWhereMethodSelectorIs: aSymbol.
	(stepsWithTheMethod isEmpty ) ifTrue: [ "Not found... should I throw an error?" ^self ].
	"find the deepest"
	deepestStepDepth := 0.
	stepsWithTheMethod do: [ :eachStep| (eachStep pathDepth >= deepestStepDepth) ifTrue: [ 
			deepestStepDepth := eachStep pathDepth.
			deepestStep := eachStep.
			 ] ].
	lastStepIndex := deepestStep executionIndex.
	"The have the last step that fulfils the condition. We want to idenify the first statement of that sequence"
   firstStatementIndex := self findStepIndexOfFirstStatementInSameSequenceOfStep: lastStepIndex.
   (firstStatementIndex <=0) ifTrue: [ self error: 'Error while finding target step' ].
   self restartAndStepToIndex: firstStatementIndex
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> goBackToTheBeginningOfLastMethodWithSelector: aSymbol [
	|stepsWithTheMethod lastStepIndex firstStatementIndex| 
	stepsWithTheMethod := self findStepsWhereMethodSelectorIs: aSymbol.
	(stepsWithTheMethod isEmpty ) ifTrue: [ "Not found... should I throw an error?" ^self ].
	lastStepIndex := stepsWithTheMethod last executionIndex.
   firstStatementIndex := self findStepIndexOfFirstStatementInSameSequenceOfStep: lastStepIndex.
   (firstStatementIndex <=0) ifTrue: [ self error: 'Error while finding target step' ].
   self restartAndStepToIndex: firstStatementIndex
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> goBackToTheBeginningOfLastMethodWithSelector: aSymbol ofClass: aClass [

	| stepsWithTheMethod lastStepIndex firstStatementIndex startingStep |
	startingStep := self currentStepDescriptor.
	stepsWithTheMethod := self
		                      findStepsWhereMethodSelectorIs: aSymbol
		                      ofClass: aClass.
	stepsWithTheMethod isEmpty ifTrue: [ "Not found... should I throw an error?" 
		^ self ].
	stepsWithTheMethod := stepsWithTheMethod reject: [ :eachStep | 
		                      eachStep isSiblingOf: startingStep ].
	lastStepIndex := stepsWithTheMethod last executionIndex.
	firstStatementIndex := self 
		                       findStepIndexOfFirstStatementInSameSequenceOfStep:
		                       lastStepIndex.
	firstStatementIndex <= 0 ifTrue: [ 
		self error: 'Error while finding target step' ].
	self restartAndStepToIndex: firstStatementIndex
]

{ #category : #accessing }
TracerVariableChanges >> indexOfAssignmentStatementOpeningStepFor: aStepDescriptor [
	|index|
	index := self reverseFindStep: [ :eachStepDescriptor| 
		(eachStepDescriptor pathDepth < aStepDescriptor pathDepth) ifTrue: [ ^0 ].
		((eachStepDescriptor pathDepth) = (aStepDescriptor pathDepth)) ifTrue: [ 
			(eachStepDescriptor hasSamePathAs: aStepDescriptor) ifTrue: [true] ifFalse: [^0].
			].
		false
		] startingIndex: (aStepDescriptor executionIndex - 1).
	^index
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> initialize [

	self reinitializeSupportFeatures.
	navigationHistory := OrderedCollection new.
	navigationForward := OrderedCollection new.
	^ super initialize
]

{ #category : #testing }
TracerVariableChanges >> isAStepAssignment: aNumber [
	^true
]

{ #category : #testing }
TracerVariableChanges >> isCurrentStepAssignment [ 
	^self currentNode statementNode isAssignment 
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> isCurrentStepMappedFinalStep [
"This requires an execution to be mapped"
 ^(currentStepIndex = endStatementDescriptor executionIndex) or: [self currentStepDescriptor hasSamePathAs: endStatementDescriptor].
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> navigateBack [
|previousStep|
navigationHistory isEmpty ifTrue: [^self inform: 'No more previous states in history.'].
previousStep := navigationHistory last.
navigationHistory removeLast.
navigationForward add: currentStepIndex.
self restartAndStepToIndex: previousStep.
	
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> navigateForward [
	|forwardStep|
navigationForward isEmpty ifTrue: [^self inform:'No more forward states'].
forwardStep := navigationForward last.
navigationForward removeLast.
navigationHistory add: currentStepIndex.
self restartAndStepToIndex: forwardStep.
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> pushNavigationHistory [
(currentStepIndex > 0 ) ifTrue:[	navigationHistory add: currentStepIndex. navigationForward removeAll] 
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> reinitializeSupportFeatures [

	trackedVariableValues := Dictionary new.
	blocksCollection := BlockRegistry new
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> restart [

	self reinitializeSupportFeatures.

	^ super restart
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> restartAndStepToCondition: aBlock [
	self restart.
	self stepUntilConditionIsTrue: aBlock.
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> restartAndStepToIndex: aNumber [
	self restart.
	self stepUntilConditionIsTrue: [currentStepIndex = aNumber].
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> restartTestAndStopAtCurrentStep [
"This is only used when neet to automap and return to the current step."
"This case is only valid for the situation when the tests fails an assertion in the main test method. If there is an unhandled exception, this is invalid."
|targetContext indexlessStepDescriptor|
targetContext := self findContextInStack: [ :aContext| aContext sender methodSelector = #performTest  ].
indexlessStepDescriptor := self createIndexlessStepDescriptorForContext: targetContext.
self restartAndStepToCondition: [ self currentStepDescriptor hasSamePathAs: indexlessStepDescriptor ].
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> restartTestAndStopAtCurrentStepForUnhandledExceptionCase [
"This is only used when neet to automap and return to the current step."

|targetContext indexlessStepDescriptor|
targetContext := self currentContext.
indexlessStepDescriptor := self createIndexlessStepDescriptorForContext: targetContext.
self restartAndStepToCondition: [ self currentStepDescriptor hasSamePathAs: indexlessStepDescriptor ].
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> restartTestAndStopAtFirstLine [
	|targetContext indexlessStepDescriptor|
targetContext := self findContextInStack: [ :aContext| aContext sender methodSelector = #performTest  ].
indexlessStepDescriptor := self createIndexlessStepDescriptorForContext: targetContext.
indexlessStepDescriptor topStatementID indexInSequence: 1.
self restartAndStepToCondition: [ self currentStepDescriptor hasSamePathAs: indexlessStepDescriptor ].
]

{ #category : #accessing }
TracerVariableChanges >> reverseFindStep: aBlock startingIndex: aNumber [
"aBlock is predicate for a stepDescriptor. If it evaluates to true, the index of such step is returned"
	|stepDescriptor|
	(aNumber > trace size) ifTrue: [ ^ 0 ].
	(aNumber <= 0) ifTrue: [ ^0 ].
	stepDescriptor := trace at: aNumber.
	(aBlock value: stepDescriptor) ifTrue: [ ^aNumber ].
	^self reverseFindStep: aBlock startingIndex: aNumber -1.
]

{ #category : #initialization }
TracerVariableChanges >> setStartingPointAndMap: aContext [
	self setSelectedContextAsStartingPoint: aContext.
	self autoMapFromStartingPoint.
]

{ #category : #accessing }
TracerVariableChanges >> stepContainsBlock: aNumber [

	blocksCollection select: [ :each | ((each at: 2) = aNumber) ifTrue:[^true ]].
	^false
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> stepForwardToNextCallOfAMethodWithSelector: aSymbol ofClass: aClass [
|startingStep foundStep|
foundStep := false.
startingStep := self currentStepDescriptor.
self stepUntilConditionIsTrue: [ 
	self isCurrentStepMappedFinalStep ifTrue: [ true ] ifFalse:[
		|aStep sequence isMatchingMethod|
		aStep := self currentStepDescriptor .
	(aStep isSiblingOf: startingStep) ifFalse:[
	sequence := aStep topStatementName sequenceStaticID.
	isMatchingMethod := ((sequence receiverClass = aClass ) and: [ sequence methodSelector = aSymbol  ]).
	isMatchingMethod ifTrue: [ foundStep := true ].
   isMatchingMethod.
	] ifTrue: [ false "it is a sibling step in the same sequence, so dont stop here"].
		]
	
].
 foundStep ifFalse: [ self inform: 'No new method call was found.' ]
	
]

{ #category : #'as yet unclassified' }
TracerVariableChanges >> stepToFinalStep [
"This requires an execution to be mapped"
self stepUntilConditionIsTrue: [self isCurrentStepMappedFinalStep].
]

{ #category : #accessing }
TracerVariableChanges >> trackedVariableName [

	^ trackedVariableName
]

{ #category : #accessing }
TracerVariableChanges >> trackedVariableName: anObject [

	trackedVariableName := anObject
]

{ #category : #accessing }
TracerVariableChanges >> trackedVariableValues [

	^ trackedVariableValues
]

{ #category : #accessing }
TracerVariableChanges >> trackedVariableValues: anObject [

	trackedVariableValues := anObject
]