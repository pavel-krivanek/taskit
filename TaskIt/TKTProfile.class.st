"
The profile is a class that represents sets of configurations. 

For adding a new profile, we have to add a class method with the pragma <profile: #name>, this method should return a TKTProfile object with it configuration.

The profile building process ensures that the profile is properly setted from the debugging point of view. 

For setting the currently working profile see in the TKTConfiguration class.
"
Class {
	#name : #TKTProfile,
	#superclass : #Object,
	#instVars : [
		'name',
		'runner',
		'process',
		'poolWorkerProcess',
		'errorHandler',
		'processProvider',
		'serviceManager',
		'debugging'
	],
	#category : #'TaskIt-Profiles'
}

{ #category : #'instance creation' }
TKTProfile class >> defaultProfile [
	^ #development
]

{ #category : #'instance creation' }
TKTProfile class >> development [
	<profile: #development>
	^ TKTProfile
		on:
			{(#debugging -> true).
			(#runner -> TKTCommonQueueWorkerPool createDefault).
			(#poolWorkerProcess -> TKTDebuggWorkerProcess).
			(#process -> TKTRawProcess).
			(#errorHandler -> TKTDebuggerExceptionHandler).
			(#processProvider -> TKTTaskItProcessProvider new).
			(#serviceManager -> TKTServiceManager new)} asDictionary
]

{ #category : #'instance creation' }
TKTProfile class >> on: aDictionary [
	^ self new
		values: aDictionary;
		yourself
]

{ #category : #'instance creation' }
TKTProfile class >> production [
	<profile: #production>
	^ TKTProfile
		on:
			{
			(#debugging -> false) .
			(#runner -> TKTCommonQueueWorkerPool createDefault).
			(#poolWorkerProcess -> TKTWorkerProcess).
			(#process -> Process).
			(#errorHandler -> TKTExceptionHandler).
			(#processProvider -> TKTPharoProcessProvider new).
			(#serviceManager -> TKTServiceManager new)} asDictionary
]

{ #category : #'instance creation' }
TKTProfile class >> profiles [
	^ (Pragma allNamed: #profile: from: self class to: ProtoObject) asOrderedCollection
		collect: [ :c | c arguments first -> (MessageSend receiver: self selector: c method selector) ]
]

{ #category : #'instance creation' }
TKTProfile class >> test [
	<profile: #test>
	^ TKTProfile
		on:
			{(#debugging -> false).
			(#runner -> TKTCommonQueueWorkerPool createDefault).
			(#poolWorkerProcess -> TKTWorkerProcess).
			(#process -> Process).
			(#errorHandler -> TKTExceptionHandler).
			(#processProvider -> TKTTaskItProcessProvider new).
			(#serviceManager -> TKTServiceManager new)} asDictionary
]

{ #category : #accessing }
TKTProfile >> activateProfile [
	self debugging
		ifTrue: [ self options
				do: [ :option | self assert: (self at: option) isDebuggingCompatible description: ('The option{1} is not debugging compatible! ' format: {option}) ].
			TKTDebugger enable ]
		ifFalse: [ TKTDebugger disable ].
	self runner start
]

{ #category : #accessing }
TKTProfile >> at: anEntry [
	^ self instVarNamed: anEntry asSymbol
]

{ #category : #accessing }
TKTProfile >> at: anEntry put: aValue [
	^ self instVarNamed: anEntry asSymbol put: aValue
]

{ #category : #accessing }
TKTProfile >> debugging [
	^ debugging
]

{ #category : #accessing }
TKTProfile >> debugging: anObject [
	debugging := anObject
]

{ #category : #accessing }
TKTProfile >> errorHandler [
	^ errorHandler
]

{ #category : #accessing }
TKTProfile >> errorHandler: anObject [
	errorHandler := anObject
]

{ #category : #accessing }
TKTProfile >> finalizeProfile [
	self options do: [ :option | (self at: option) finalize ]
]

{ #category : #accessing }
TKTProfile >> name [
	^ name
]

{ #category : #accessing }
TKTProfile >> name: anObject [
	name := anObject
]

{ #category : #accessing }
TKTProfile >> options [
	^ #(runner process poolWorkerProcess errorHandler processProvider serviceManager)
]

{ #category : #accessing }
TKTProfile >> poolWorkerProcess [
	^ poolWorkerProcess
]

{ #category : #accessing }
TKTProfile >> poolWorkerProcess: anObject [
	poolWorkerProcess := anObject
]

{ #category : #accessing }
TKTProfile >> process [
	^ process
]

{ #category : #accessing }
TKTProfile >> process: anObject [
	process := anObject
]

{ #category : #accessing }
TKTProfile >> processProvider [
	^ processProvider
]

{ #category : #accessing }
TKTProfile >> processProvider: anObject [
	processProvider := anObject
]

{ #category : #accessing }
TKTProfile >> runner [
	^ runner
]

{ #category : #accessing }
TKTProfile >> runner: anObject [
	runner := anObject
]

{ #category : #accessing }
TKTProfile >> serviceManager [
	^ serviceManager
]

{ #category : #accessing }
TKTProfile >> serviceManager: anObject [
	serviceManager := anObject
]

{ #category : #accessing }
TKTProfile >> values: aDictionary [
	aDictionary keysAndValuesDo: [ :k :v | self perform: ('{1}:' format: {k}) asSymbol withArguments: {v} ]
]
