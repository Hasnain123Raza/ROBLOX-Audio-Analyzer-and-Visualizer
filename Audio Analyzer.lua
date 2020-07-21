local CLASS = {}

--// SERVICES //--

local RUN_SERVICE = game:GetService("RunService")

--// CONSTANTS //--



--// VARIABLES //--



--// CONSTRUCTOR //--

function CLASS.new()
	local dataTable = setmetatable(
		{
			
		},
		CLASS
	)
	local proxyTable = setmetatable(
		{
			
		},
		{
			__index = function(self, index)
				return dataTable[index]
			end,
			__newindex = function(self, index, newValue)
				dataTable[index] = newValue
			end
		}
	)
	
	return proxyTable
end

--// FUNCTIONS //--

local function loadSound(sound)
	local timeStamp = tick()
	repeat wait(1) until (sound.TimeLength > 0) or (tick() - timeStamp > 5)
	if (sound.TimeLength == 0) then
		error("Sound Analyzer Timeout Error: Sound took too long to load or is of length 0")
	end
end

local function getMeanFromArray(array)
	local mean = 0
	for _, value in pairs(array) do
		mean = mean + value
	end
	return mean/#array
end

local function getMedianFromArray(array)
	table.sort(array, function(a, b) return a > b end)
	return array[math.ceil(#array/2)]
end

local function shallowClone(targetTable)
	local clone = {}
	for _, value in pairs(targetTable) do
		table.insert(clone, value)
	end
	return clone
end


--// METHODS //--

function CLASS:processSoundByResolution(sound, sampleResolution)
	assert(sound ~= nil, "Sound Analyzer Argument Error: Sound expected, got nil")
	assert(typeof(sound) == "Instance", "Sound Analyzer Argument Error: Sound expected, got " .. typeof(sound))
	assert(sound.ClassName == "Sound", "Sound Analyzer Argument Error: Sound expected, got " .. sound.ClassName)
	assert(sampleResolution ~= nil, "Sound Analyzer Argument Error: number expected, got nil")
	assert(typeof(sampleResolution) == "number", "Sound Analyzer Argument Error: number expected, got " .. typeof(sampleResolution))
	assert(sampleResolution > 0, "Sound Analyzer Argument Error: sampleResolution (" .. sampleResolution .. ") must be a positive value")
	
	loadSound(sound)
	
	return self:processSoundByPlaybackSpeed(sound, (sound.TimeLength * 60)/sampleResolution)
end

function CLASS:processSoundByTime(sound, sampleTime)
	assert(sound ~= nil, "Sound Analyzer Argument Error: Sound expected, got nil")
	assert(typeof(sound) == "Instance", "Sound Analyzer Argument Error: Sound expected, got " .. typeof(sound))
	assert(sound.ClassName == "Sound", "Sound Analyzer Argument Error: Sound expected, got " .. sound.ClassName)
	assert(sampleTime ~= nil, "Sound Analyzer Argument Error: number expected, got nil")
	assert(typeof(sampleTime) == "number", "Sound Analyzer Argument Error: number expected, got " .. typeof(sampleTime))
	assert(sampleTime > 0, "Sound Analyzer Argument Error: sampleTime (" .. sampleTime .. ") must be a positive value")
	
	loadSound(sound)
	
	return self:processSoundByPlaybackSpeed(sound, sound.TimeLength/sampleTime)
end

function CLASS:processSoundByPlaybackSpeed(sound, samplePlaybackSpeed)
	assert(sound ~= nil, "Sound Analyzer Argument Error: Sound expected, got nil")
	assert(typeof(sound) == "Instance", "Sound Analyzer Argument Error: Sound expected, got " .. typeof(sound))
	assert(sound.ClassName == "Sound", "Sound Analyzer Argument Error: Sound expected, got " .. sound.ClassName)
	assert(samplePlaybackSpeed ~= nil, "Sound Analyzer Argument Error: number expected, got nil")
	assert(typeof(samplePlaybackSpeed) == "number", "Sound Analyzer Argument Error: number expected, got " .. typeof(samplePlaybackSpeed))
	if (samplePlaybackSpeed < 0.01) or (samplePlaybackSpeed > 20) then
		warn("Sound Analyzer Argument Warning: PlaybackSpeed (" .. samplePlaybackSpeed .. ") must be between 0.01 or 20 otherwise quality will be affected")
	end
	
	loadSound(sound)
	
	local sampledSound = self:sampleSoundByPlaybackSpeed(sound, samplePlaybackSpeed)
	local soundData = self:processSampledSound(sampledSound)
	return soundData
end

function CLASS:sampleSoundByPlaybackSpeed(sound, samplePlaybackSpeed)
	local clone = sound:Clone()
	clone.Parent = script
	loadSound(clone)
	clone.Volume = 0
	clone.PlaybackSpeed = samplePlaybackSpeed
	clone.Looped = false
	local sampledTimePosition, sampledPlaybackLoudness = {}, {}
	local timePosition = 0
	local ended = false
	
	local sampleConnection
	sampleConnection = RUN_SERVICE.Stepped:Connect(function(_, dt)
		if (ended) then
			sampleConnection:Disconnect()
		else
			timePosition = timePosition + dt
			table.insert(sampledTimePosition, timePosition * samplePlaybackSpeed)
			table.insert(sampledPlaybackLoudness, clone.PlaybackLoudness)
		end
	end)
	local endedConnection
	endedConnection = clone.Ended:Connect(function()
		endedConnection:Disconnect()
		ended = true
	end)
	clone:Play()
	clone.Ended:wait()
	clone:Destroy()
	return {sampledTimePosition = sampledTimePosition, sampledPlaybackLoudness = sampledPlaybackLoudness}
end

function CLASS:processSampledSound(sampledSound)
	local highest, lowest = 0, 0
	local mean = 0
	local range = 0
	local median = 0
	
	local clonedSampledPlaybackLoudness = shallowClone(sampledSound.sampledPlaybackLoudness)
	table.sort(clonedSampledPlaybackLoudness, function(a, b) return a > b end)
	highest = clonedSampledPlaybackLoudness[1]
	table.sort(clonedSampledPlaybackLoudness, function(a, b) return a < b end)
	lowest = clonedSampledPlaybackLoudness[1]
	mean = getMeanFromArray(clonedSampledPlaybackLoudness)
	median = getMedianFromArray(clonedSampledPlaybackLoudness)
	range = (highest - lowest)
	
	return {
		playbackLoudnessArray = sampledSound.sampledPlaybackLoudness,
		timePositionArray = sampledSound.sampledTimePosition,
		highest = highest,
		lowest = lowest,
		mean = mean,
		median = median,
		range = range
	}
end

--// INSTRUCTIONS //--

CLASS.__index = CLASS

return CLASS
