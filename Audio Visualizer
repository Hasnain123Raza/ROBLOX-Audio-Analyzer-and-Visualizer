local CLASS = {}

--// SERVICES //--

local RUN_SERVICE = game:GetService("RunService")

--// CONSTANTS //--



--// VARIABLES //--



--// CONSTRUCTOR //--

function CLASS.new(soundData)
	assert(soundData ~= nil, "Sound Visualizer Argument Error: table expected for soundData, got nil")
	assert(typeof(soundData) == "table", "Sound Visualizer Argument Error: table expected for soundData, got " .. typeof(soundData))
	
	local dataTable = setmetatable(
		{
			soundData = soundData
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



--// METHODS //--

function CLASS:getPlaybackLoudness(timePosition)
	assert(timePosition ~= nil, "Sound Visualizer Argument Error: number expected, got nil")
	assert(typeof(timePosition) == "number", "Sound Visualizer Argument Error: number expected, got " .. typeof(timePosition))
	assert(timePosition >= 0, "Sound Visualizer Argument Error: timePosition (" .. timePosition .. ") must be a positive value")
	
	local lowerIndex, upperIndex
	local timePositionArray = self.soundData.timePositionArray
	local playbackLoudnessArray = self.soundData.playbackLoudnessArray
	for counter = 1, #timePositionArray do
		local timePositionRecord = timePositionArray[counter]
		if (timePosition - timePositionRecord < 0) then
			lowerIndex = counter - 1
			upperIndex = counter
			break
		end
	end
	if (lowerIndex == nil) or (upperIndex == nil) then
		return nil
	end
	
	local lowerTimePosition, upperTimePosition = timePositionArray[lowerIndex], timePositionArray[upperIndex]
	local lowerPlaybackLoudness, upperPlaybackLoudness = playbackLoudnessArray[lowerIndex], playbackLoudnessArray[upperIndex]
	if (lowerTimePosition == nil) or (upperTimePosition == nil) or (lowerPlaybackLoudness == nil) or (upperPlaybackLoudness == nil) then
		return nil
	end
	
	local alpha = (timePosition - lowerTimePosition)/(upperTimePosition - lowerTimePosition)
	local resultPlaybackLoudness = lowerPlaybackLoudness + ((upperPlaybackLoudness - lowerPlaybackLoudness) * alpha)
	return resultPlaybackLoudness
end

function CLASS:getNormalizedPlaybackLoudness(timePosition)
	assert(timePosition ~= nil, "Sound Visualizer Argument Error: number expected, got nil")
	assert(typeof(timePosition) == "number", "Sound Visualizer Argument Error: number expected, got " .. typeof(timePosition))
	assert(timePosition >= 0, "Sound Visualizer Argument Error: timePosition (" .. timePosition .. ") must be a positive value")
	
	local playbackLoudness = self:getPlaybackLoudness(timePosition)
	if (playbackLoudness) then
		return playbackLoudness/self.soundData.range
	else
		return nil
	end
end

--// INSTRUCTIONS //--

CLASS.__index = CLASS

return CLASS
