"
Common queue worker pool has in common queue. This makes that all the workers wait over the same queue 
"
Class {
	#name : #TKTCommonQueueWorkerPool,
	#superclass : #Object,
	#traits : 'TTaskScheduler - {#scheduleTaskExecution:}',
	#classTraits : 'TTaskScheduler classTrait',
	#instVars : [
		'poolMaxSize',
		'workers',
		'taskQueue',
		'failedTasks',
		'name',
		'dog',
		'mutex'
	],
	#category : #'TaskIt-Worker'
}

{ #category : #current }
TKTCommonQueueWorkerPool class >> createDefault [
	^ self new
		name: 'CommonPool-' , UUID new asString;
		poolMaxSize: 4;
		yourself
]

{ #category : #public }
TKTCommonQueueWorkerPool >> ensureIsBeingWatched [
	dog ifNotNil: [ dog ensureIsAwake ]
]

{ #category : #'public - mutexed' }
TKTCommonQueueWorkerPool >> ensureIsWorking [
	mutex
		critical: [ failedTasks
				add: (self workers reject: #isRunning thenCollect: #currentTaskExecution).
			failedTasks
				ifNotEmpty:
					[ self logCr: failedTasks size asString , ' Failed tasks encountered' ].
			(workers reject: #isRunning)
				do: [ :w | 
					w stop.
					workers remove: w ].
			self privateManageWorkersBefore.
			self privateManageWorkersAfter ]
]

{ #category : #public }
TKTCommonQueueWorkerPool >> failedTasks [
	^ failedTasks copy
]

{ #category : #initialization }
TKTCommonQueueWorkerPool >> initialize [
	super initialize.
	workers := Set new.
	failedTasks := OrderedCollection new.
	taskQueue := AtomicSharedQueue new.
	mutex := Mutex new.
	self name: 'Worker' , self identityHash asString.
	
]

{ #category : #configuration }
TKTCommonQueueWorkerPool >> isDebuggingCompatible [
	^ true
]

{ #category : #public }
TKTCommonQueueWorkerPool >> name [
	^ name
]

{ #category : #public }
TKTCommonQueueWorkerPool >> name: aString [
	name := aString
]

{ #category : #'public - mutexed' }
TKTCommonQueueWorkerPool >> poolMaxSize: anInteger [
	mutex critical: [ poolMaxSize := anInteger ]
]

{ #category : #'public - mutexed' }
TKTCommonQueueWorkerPool >> printOn: aStream [
	| freeWorkers |
	mutex
		critical: [ freeWorkers := self privateFreeWorkers.
			aStream
				nextPutAll: 'TKTCommonQueueWorkerPool(';
				nextPutAll: 'name:';
				nextPutAll: name;
				nextPutAll: 'poolMaxSize: ';
				print: poolMaxSize;
				nextPutAll: '; busyWorkers: ';
				print: workers size - freeWorkers size;
				nextPutAll: '; freeWorkers: ';
				print: freeWorkers size;
				nextPutAll: ')' ]
]

{ #category : #private }
TKTCommonQueueWorkerPool >> privateFreeWorkers [
	^ workers select: [ :each | each isFree ]
]

{ #category : #private }
TKTCommonQueueWorkerPool >> privateManageWorkersAfter [
	| free toremove |
	toremove := workers reject: #isRunning.
	toremove do: [ :w | w stop ].
	free := self privateFreeWorkers.
	taskQueue size > free size
		ifTrue: [ self privateSpawnWorkerIfNeeded ]
]

{ #category : #private }
TKTCommonQueueWorkerPool >> privateManageWorkersBefore [
	| free |
	free := self privateFreeWorkers.
	free size * 100 / (workers size max: 1) > 50
		ifTrue: [ self privateRemoveIdleWorkerIfNeeded ]
]

{ #category : #private }
TKTCommonQueueWorkerPool >> privateNewWorker [
	workers
		add:
			(TKTWorker new
				name: self name , ' Worker #' , (self size + 1) asString;
				taskQueue: taskQueue;
				start)
]

{ #category : #private }
TKTCommonQueueWorkerPool >> privateRemoveIdleWorkerIfNeeded [
	| removing free |
	free := self privateFreeWorkers.
	free size < taskQueue size
		ifTrue: [ ^ self ].
	removing := free anyOne.
	removing stop.
	workers remove: removing
]

{ #category : #private }
TKTCommonQueueWorkerPool >> privateSpawnWorkerIfNeeded [
	workers size < poolMaxSize
		ifTrue: [ self privateNewWorker ]
]

{ #category : #public }
TKTCommonQueueWorkerPool >> purge [
	taskQueue removeAll
]

{ #category : #'public - mutexed' }
TKTCommonQueueWorkerPool >> reset [
	mutex
		critical: [ self purge.
			workers do: #restart ]
]

{ #category : #'public - mutexed' }
TKTCommonQueueWorkerPool >> scheduleTaskExecution: aTaskExecution [
	mutex
		critical: [ self ensureIsBeingWatched.
			self privateManageWorkersBefore.
			taskQueue nextPut: aTaskExecution.
			self privateManageWorkersAfter ]
]

{ #category : #public }
TKTCommonQueueWorkerPool >> size [
	^ workers size
]

{ #category : #'public - mutexed' }
TKTCommonQueueWorkerPool >> start [
	mutex
		critical: [ dog
				ifNil: [ dog := TKTWatchDog on: self ]
				ifNotNil: [ self error: 'Already started' ] ]
]

{ #category : #'public - mutexed' }
TKTCommonQueueWorkerPool >> stop [
	mutex
		critical: [ dog := nil.
			workers do: #stop.
			workers removeAll ]
]

{ #category : #public }
TKTCommonQueueWorkerPool >> workers [
	
	^ workers copy
]
