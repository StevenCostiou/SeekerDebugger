Class {
	#name : #SkExecutionVirtualTableCreator,
	#superclass : #Object,
	#instVars : [
		'tracer'
	],
	#category : #'Seeker-Components-Experimental'
}

{ #category : #'as yet unclassified' }
SkExecutionVirtualTableCreator >> omniscientSlimTable [

	| csi virtualTable |

	csi := tracer currentStateInterface.
	virtualTable := SkExecutionVirtualTable
		                newWithRowReificationBlock: [ 
			                SkNew with: { 
					                (#stepIndex -> csi tracedStatementStepIndex).
					                (#receiverClass -> csi receiverClass).
					                "(#node -> csi node)."
					                (#context -> csi context).
					                (#contextPC -> csi contextPC).
					                (#initialPC -> csi initialPC).
					                (#endPC -> csi endPC).
					               " (#sequenceNode -> csi sequenceNode).
					                (#statementNode -> csi statementNode)."
					                (#statementIndex -> csi statementIndex).
					                (#sequenceStatementCount
					                 -> csi sequenceStatementCount).
					                (#methodSelector -> csi methodSelector).
					                (#bytecodeIndex -> csi bytecodeIndex) } ]
		                forTracer: tracer.
	^ virtualTable join: tracer tables tableOfAliases
]

{ #category : #'as yet unclassified' }
SkExecutionVirtualTableCreator >> omniscientTable [

	| csi virtualTable instancesDictionary getCreationStep |
	instancesDictionary := IdentityDictionary new. "TODO add an onFinish to the table so I can clear the dictionary"
	getCreationStep := [ :objInst :stepIndex | 
	                   (instancesDictionary includesKey: objInst)
		                   ifTrue: [ instancesDictionary at: objInst ]
		                   ifFalse: [ 
			                   instancesDictionary at: objInst put: stepIndex.
			                   stepIndex ] ].

	csi := tracer currentStateInterface.
	virtualTable := SkExecutionVirtualTable
		                newWithRowReificationBlock: [ 
			                SkNew with: { 
					                (#bytecodeIndex -> csi bytecodeIndex).
					                (#bytecodeStepInTracedStatement
					                 -> csi bytecodeStepInTracedStatement).
					                (#creationStep -> (getCreationStep
						                  value: csi receiver
						                  value: csi tracedStatementStepIndex)).

					                (#context -> csi context).
					                (#contextPC -> csi contextPC).
					                (#initialPC -> csi initialPC).
					                (#endPC -> csi endPC).

					                (#methodSelector -> csi methodSelector).
					                (#node -> csi node).
					                (#receiver -> csi receiver).
					                (#receiverClass -> csi receiverClass).

					                (#statementIndex -> csi statementIndex).
					                (#statementNode -> csi statementNode).
					                (#statementNotation
					                 -> csi statementNotation asString).
					                (#stepIndex -> csi tracedStatementStepIndex).
					                (#stackDepth -> csi stackDepth).
					                (#sequenceNode -> csi sequenceNode).

					                (#sequenceStatementCount
					                 -> csi sequenceStatementCount).
					                (#tracedStatementDescriptor
					                 -> csi tracedStatementDescriptor).
					                (#sourceCodeOfNode -> csi node sourceCode).
					                (#sourceCodeOfStatementNode
					                 -> csi statementNode sourceCode) } ]
		                forTracer: tracer.
	^ virtualTable
]

{ #category : #'as yet unclassified' }
SkExecutionVirtualTableCreator >> tableForTrackingChanges [

	| csi virtualTable  |
	csi := tracer currentStateInterface.
	virtualTable := SkExecutionVirtualTableWithMemory
		                newWithRowReificationBlock: [ 
			                SkNew with: { 
					                (#stepIndex -> csi tracedStatementStepIndex).
					                (#receiverClass -> csi receiverClass).
					                (#methodSelector -> csi methodSelector).
					                (#bytecodeIndex -> csi bytecodeIndex).
										 (#context -> csi context)
					                "#previousRow -> execution previous Row" }
			                "Tables with memory add an additional column called #previousRow" ]
		                forTracer: tracer.

	^ virtualTable
]

{ #category : #accessing }
SkExecutionVirtualTableCreator >> tableOfAliases [

	| csi virtualTable instancesDictionary getCreationStep |
	instancesDictionary := IdentityDictionary new. "TODO add an onFinish to the table so I can clear the dictionary"
	getCreationStep := [ :objInst :stepIndex | 
	                   (instancesDictionary includesKey: objInst)
		                   ifTrue: [ instancesDictionary at: objInst ]
		                   ifFalse: [ 
			                   instancesDictionary at: objInst put: stepIndex.
			                   stepIndex ] ].
	csi := tracer currentStateInterface.
	virtualTable := SkExecutionVirtualTable
		                newWithRowReificationBlock: [ 
			                SkNew with: { 
					                (#stepIndex -> csi tracedStatementStepIndex).
					                "(#receiverClass -> csi receiverClass).
					                (#methodSelector -> csi methodSelector).
					                (#isFirstBytecode -> csi isFirstBytecodeOfMethod)."
					                (#creationStep -> (getCreationStep
						                  value: csi receiver
						                  value: csi tracedStatementStepIndex)).
					                (#bytecodeIndex -> csi bytecodeIndex) } ]
		                forTracer: tracer.

	^ virtualTable
]

{ #category : #'as yet unclassified' }
SkExecutionVirtualTableCreator >> tableOfContextSizes [

	| csi virtualTable |
	csi := tracer currentStateInterface.
	virtualTable := SkExecutionVirtualTableWithMemory
		                newWithRowReificationBlock: [ 
			                SkNew with: { 
					                (#stepIndex -> csi tracedStatementStepIndex).
					                (#receiverClass -> csi receiverClass).
					                (#methodSelector -> csi methodSelector).
					                (#bytecodeIndex -> csi bytecodeIndex).
					                (#contextSize -> csi context size) } ]
		                forTracer: tracer.
	^ virtualTable
]

{ #category : #accessing }
SkExecutionVirtualTableCreator >> tableOfMethods [

	| csi virtualTable |
	
	csi := tracer currentStateInterface.
	virtualTable := SkExecutionVirtualTable
		                newWithRowReificationBlock: [ 
			                SkNew with: { 
					                (#stepIndex -> csi tracedStatementStepIndex).
					                (#receiverClass -> csi receiverClass).
					                (#methodSelector -> csi methodSelector).
					                (#bytecodeIndex -> csi bytecodeIndex) } ]
		                forTracer: tracer.

	^ virtualTable
]

{ #category : #accessing }
SkExecutionVirtualTableCreator >> tableOfReturnValues [

	| csi virtualTable |
	csi := tracer currentStateInterface.
	virtualTable := SkExecutionVirtualTable
		                newWithRowReificationBlock: [ 
			                SkNew with: { 
					                (#stepIndex -> csi tracedStatementStepIndex).
					                (#receiverClass -> csi receiverClass).
					                (#methodSelector -> csi methodSelector).
					                (#returnValue -> csi methodReturnValue).
					                (#contextPC -> csi contextPC).
					                (#endPC -> csi endPC) } ]
		                forTracer: tracer.

	^ virtualTable
]

{ #category : #accessing }
SkExecutionVirtualTableCreator >> tableOfStatementSourceCode [

	| csi virtualTable |
	csi := tracer currentStateInterface.
	virtualTable := SkExecutionVirtualTable
		                newWithRowReificationBlock: [ 
			                SkNew with: { 
					                (#stepIndex -> csi tracedStatementStepIndex).
					                (#statementSourceCode
					                 -> csi sourceCodeOfStatement).
					                (#bytecodeStepInTracedStatement
					                 -> csi bytecodeStepInTracedStatement).
					                (#bytecodeIndex -> csi bytecodeIndex) } ]
		                forTracer: tracer.

	^ virtualTable
]

{ #category : #'as yet unclassified' }
SkExecutionVirtualTableCreator >> tableWithMemoryOfContextSizes [

	"Tables with memory add an additional column called #previousRow"

	^ self tableOfContextSizes asTableWithMemory
]

{ #category : #accessing }
SkExecutionVirtualTableCreator >> tracer [

	^ tracer
]

{ #category : #accessing }
SkExecutionVirtualTableCreator >> tracer: anObject [

	tracer := anObject
]