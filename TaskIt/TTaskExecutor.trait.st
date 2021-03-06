"
I am a trait implementing the main behavior of a task executor. That is, an object that knows how to execute a task and handle its unhandled exceptions using an exception handler
"
Trait {
	#name : #TTaskExecutor,
	#category : 'TaskIt-Kernel'
}

{ #category : #testing }
TTaskExecutor classSide >> isDebuggingCompatible [
	^ false
]

{ #category : #accessing }
TTaskExecutor >> exceptionHandler [

	self shouldBeImplemented 
]

{ #category : #executing }
TTaskExecutor >> executeTask: aTaskExecution [
	[ self noteBusy. aTaskExecution value. self noteFree ]
		on: Error
		do: [ :error | self exceptionHandler handleException: error ]
]

{ #category : #'as yet unclassified' }
TTaskExecutor >> isDebuggingCompatible [
	^ false
]

{ #category : #'as yet unclassified' }
TTaskExecutor >> noteBusy [

	self shouldBeImplemented
]

{ #category : #'as yet unclassified' }
TTaskExecutor >> noteFree [

	self shouldBeImplemented
]
