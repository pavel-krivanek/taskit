Class {
	#name : #TKTWorkerPoolTests,
	#superclass : #TKTTestCase,
	#category : 'TaskIt-Tests-Worker'
}

{ #category : #tests }
TKTWorkerPoolTests >> testWorkerPoolCretesWorkersWhenExecutingATask [
	| pool |
	pool := TKTWorkerPool new.
	pool name: 'test pool'.
	pool poolMaxSize: 4.
	pool start.
	(pool future: [ 1 ]) waitForCompletion: 1 second.
	self assert: pool workers notEmpty
]

{ #category : #tests }
TKTWorkerPoolTests >> testWorkerPoolDoesNotExceedPoolSize [

	| pool |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 4.
	pool start.
		
	((1 to: 10) collect: [:i | pool future: [ 1 + 1 ] ])
		do: [ :future | future waitForCompletion: 1 second. ].
	
	self assert: pool size equals: 4
]

{ #category : #tests }
TKTWorkerPoolTests >> testWorkerPoolDoesNotExceedPoolSizeWhenSchedulingTasksInParallel [

	| pool totalTasks futures |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 10.
	pool start.
	totalTasks := 0.
		
	futures := AtomicSharedQueue new.
	1 to: 10 do: [:i | 
		futures nextPut: (pool future: [ 
			10 timesRepeat: [ futures nextPut: (pool future: [
					totalTasks := totalTasks + 1 ]) ] ]) ].
	
	[ futures isEmpty ] whileFalse: [ futures next waitForCompletion: 100 milliSeconds ].
	
	self assert: totalTasks equals: 100.
	self assert: pool size equals: 10
]

{ #category : #tests }
TKTWorkerPoolTests >> testWorkerPoolStopStopsWorkers [

	| pool |
	pool := TKTWorkerPool new.
	pool poolMaxSize: 4.
	pool start.
		
	((1 to: 10) collect: [:i | pool future: [ 1 + 1 ] ])
		do: [ :future | future waitForCompletion: 500 milliSeconds. ].
	
	pool stop.
	
	pool workers do: [ :worker | self deny: worker isRunning ].
]

{ #category : #tests }
TKTWorkerPoolTests >> testWorkerPoolWorkersAreStoppedAfterPoolsCollection [

	| pool workerProcess |
	pool := TKTWorkerPool new.
	pool name: 'test pool'.
	pool poolMaxSize: 4.
	pool start.
		
	(pool future: [ 1 ])
		waitForCompletion: 1 second.

	self assert: pool workers notEmpty.
	
	workerProcess := WeakArray with: pool workers anyOne process.
	
	pool := nil.
	self garbageCollectAndWait .

	self assert: workerProcess first isNil.
]

{ #category : #tests }
TKTWorkerPoolTests >> testWorkerPoolWorkersProcessesAreStoppedAfterPoolsCollection [
	| pool workerProcess |
	pool := TKTWorkerPool new.
	pool name: 'test pool'.
	pool poolMaxSize: 4.
	pool start.
		
	(pool future: [ 1 ])
		waitForCompletion: 1 second.

	workerProcess := WeakArray with: pool workers anyOne process process.
	
	pool := nil.
	self garbageCollectAndWait .

	self assert: workerProcess first isNil
]

{ #category : #tests }
TKTWorkerPoolTests >> testWorkerPoolWorkersProcessesAreTerminatedAfterPoolsCollection [
	| pool workerProcess |
	pool := TKTWorkerPool new.
	pool name: 'Test pool'.
	pool poolMaxSize: 4.
	pool start.
	(pool future: [ 1 ]) waitForCompletion: 1 second.
	workerProcess := pool workers anyOne process process.
	pool := nil.
 	self garbageCollectAndWait .
	self assert: workerProcess isTerminated
]
