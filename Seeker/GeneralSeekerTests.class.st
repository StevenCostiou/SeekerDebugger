Class {
	#name : #GeneralSeekerTests,
	#superclass : #TestCase,
	#category : #'Seeker-BugCollection-Tests'
}

{ #category : #tests }
GeneralSeekerTests >> testCreateIndexlessStepDescriptorForConditionInStack [
	"launch the test and when the debugger opens with the failing assertion, evaluate 
	|targetContext|
	targetContext := seeker stepper findContextInStack: [:aContext| aContext selector = #testCreateIndexlessStepDescriptorForConditionInStack].
	seeker stepper createIndexlessStepDescriptorForContext: targetContext
	"
	|aCol | 
	
	aCol:= OrderedCollection new.
	aCol add: 1.
	aCol add: 1.
	
	self assert: false
]

{ #category : #tests }
GeneralSeekerTests >> testFamixJavaclass [

"This reproduces the recursion in Anne's bug case. But first need to deploy the debugger to that image."

	|result|
	result := FamixJavaClass rootAccordingTo: Object.
	self assert: false
]

{ #category : #tests }
GeneralSeekerTests >> testFindInStack [
	"launche the test and when the debugger opens with the failing assertion, evaluate 
	seeker stepper findContextInStack: [:aContext| aContext selector = #testFindInStack]
	"
	|aCol | 
	
	aCol:= OrderedCollection new.
	aCol add: 1.
	aCol add: 1.
	
	self assert: false
]

{ #category : #tests }
GeneralSeekerTests >> testFindTestContextInStack [
	"launches the test and when the debugger opens with the failing assertion, evaluate 
	seeker stepper findTestContext
	"
	|aCol | 
	
	aCol:= OrderedCollection new.
	aCol add: 1.
	aCol add: 1.
	
	self assert: false
]

{ #category : #tests }
GeneralSeekerTests >> testVariableTracking [

	"Do this once the window opens:
	seeker stepper trackedVariableName: 'aNumber'
	then remap the test
	"

	| aCol aNumber |
	aNumber := -1.
	aNumber := 0.
	aCol := OrderedCollection new.
	aCol add: 1.
	aCol add: 1.
	aNumber := aCol size.
	aCol := OrderedCollection new.
	aCol add: 1.
	aCol add: 1.
	aNumber := aCol size.

	self assert: false
]