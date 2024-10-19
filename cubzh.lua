math.randomseed(math.floor(Time.UnixMilli() % 100000))

Modules = {
	gigax = "github.com/GigaxGames/integrations/cubzh:9a71b9f",
	pathfinding = "github.com/caillef/cubzh-library/pathfinding:5f9c6bd",
	floating_island_generator = "github.com/caillef/cubzh-library/floating_island_generator:82d22a5",
	easy_onboarding = "github.com/caillef/cubzh-library/easy_onboarding:77728ee",
}

Config = {
	Items = { "pratamacam.squirrel" },
}

-- Function to spawn a squirrel above the player
function spawnSquirrelAbovePlayer(player)
	local squirrel = Shape(Items.pratamacam.squirrel)
	squirrel:SetParent(World)
	squirrel.Position = player.Position + Number3(0, 20, 0)
	-- make scale smaller
	squirrel.LocalScale = 0.5
	-- remove collision
	squirrel.Physics = PhysicsMode.Dynamic
	-- rotate it 90 degrees to the right
	squirrel.Rotation = { 0, math.pi * 0.5, 0 }
	-- this would make squirrel.Rotation = player.Rotation
	World:AddChild(squirrel)
	return squirrel
end

local SIMULATION_NAME = "Islands" .. tostring(math.random())
local SIMULATION_DESCRIPTION = "Three floating islands."


local skills = {
	{
		name = "SAY",
		description = "Say smthg out loud",
		parameter_types = { "character", "content" },
		callback = function(client, action)
			local npc = client:getNpc(action.character_id)
			if not npc then
				print("Can't find npc")
				return
			end
			dialog:create(action.content, npc.avatar.Head)
			print(string.format("%s: %s", npc.gameName, action.content))
		end,
		action_format_str = "{protagonist_name} said '{content}' to {target_name}",
	},
	{
		name = "MOVE",
		description = "Move to a new location",
		parameter_types = { "location" },
		callback = function(client, action, config)
			local targetName = action.target_name
			local targetPosition = findLocationByName(targetName, config)
			if not targetPosition then
				print("tried to move to an unknown place", targetName)
				return
			end
			local npc = client:getNpc(action.character_id)
			dialog:create("I'm going to " .. targetName, npc.avatar.Head)
			print(string.format("%s: %s", npc.gameName, "I'm going to " .. targetName))
			local origin = Map:WorldToBlock(npc.object.Position)
			local destination = Map:WorldToBlock(targetPosition) + Number3(math.random(-1, 1), 0, math.random(-1, 1))
			local canMove = pathfinding:moveObjectTo(npc.object, origin, destination)
			if not canMove then
				dialog:create("I can't go there", npc.avatar.Head)
				return
			end
		end,
		action_format_str = "{protagonist_name} moved to {target_name}",
	},
	{
		name = "GREET",
		description = "Greet a character by waving your hand at them",
		parameter_types = { "character" },
		callback = function(client, action)
			local npc = client:getNpc(action.character_id)
			if not npc then
				print("Can't find npc")
				return
			end

			dialog:create("<Greets you warmly!>", npc.avatar.Head)
			print(string.format("%s: %s", npc.gameName, "<Greets you warmly!>"))

			npc.avatar.Animations.SwingRight:Play()
		end,
		action_format_str = "{protagonist_name} waved their hand at {target_name} to greet them",
	},
	{
		name = "JUMP",
		description = "Jump in the air",
		parameter_types = {},
		callback = function(client, action)
			local npc = client:getNpc(action.character_id)
			if not npc then
				print("Can't find npc")
				return
			end

			dialog:create("<Jumps in the air!>", npc.avatar.Head)
			print(string.format("%s: %s", npc.gameName, "<Jumps in the air!>"))

			npc.object.avatarContainer.Physics = PhysicsMode.Dynamic
			npc.object.avatarContainer.Velocity.Y = 50
			Timer(3, function()
				npc.object.avatarContainer.Physics = PhysicsMode.Trigger
			end)
		end,
		action_format_str = "{protagonist_name} jumped up in the air for a moment.",
	},
	{
		name = "FOLLOW",
		description = "Follow a character around for a while",
		parameter_types = { "character" },
		callback = function(client, action)
			local npc = client:getNpc(action.character_id)
			if not npc then
				print("Can't find npc")
				return
			end

			dialog:create("I'm following you", npc.avatar.Head)
			print(string.format("%s: %s", npc.gameName, "I'm following you"))

			followHandler = pathfinding:followObject(npc.object, Player)
			return {
				followHandler = followHandler,
			}
		end,
		onEndCallback = function(_, data)
			data.followHandler:Stop()
		end,
		action_format_str = "{protagonist_name} followed {target_name} for a while.",
	},
	{
		name = "FIRECRACKER",
		description = "Perform a fun, harmless little explosion to make people laugh!",
		parameter_types = { "character" },
		callback = function(client, action)
			local npc = client:getNpc(action.character_id)
			if not npc then
				print("Can't find npc")
				return
			end

			require("explode"):shapes(npc.avatar)
			dialog:create("*boom*", npc.avatar.Head)
			npc.avatar.IsHidden = true
			Timer(5, function()
				dialog:create("Aaaaand... I'm back!", npc.avatar.Head)
				npc.avatar.IsHidden = false
			end)
		end,
		action_format_str = "{protagonist_name} exploded like a firecracker, with a bang!",
	},--[[
	{
        name = "GIVEAPPLE",
        description = "Give a pice of bread (or a baguette) to someone",
        parameter_types = {"character"},
        callback = function(client, action)
			local npc = client:getNpc(action.character_id)
			if not npc then print("Can't find npc") return end
			local shape = MutableShape()
			shape:AddBlock(Color.Red, 0, 0, 0)
			shape.Scale = 4
			Player:EquipRightHand(shape)
			dialog:create("Here is an apple for you!", npc.avatar.Head)
        end,
		action_format_str = "{protagonist_name} gave you a piece of bread!"
    }, --]]
	{
        name = "GIANT",
        description = "Double your height to become a giant for a few seconds.",
        parameter_types = {"character"},
        callback = function(client, action)
			local npc = client:getNpc(action.character_id)
			if not npc then print("Can't find npc") return end

			npc.object.Scale = npc.object.Scale * 2
			dialog:create("I am taller than you now!", npc.avatar.Head)
        end,
		action_format_str = "{protagonist_name} doubled his height!"
    },
	{
		name = "GIVEHAT",
		description = "Give a party hat to someone",
		parameter_types = { "character" },
		callback = function(client, action)
			local npc = client:getNpc(action.character_id)
			if not npc then
				print("Can't find npc")
				return
			end

			Object:Load("claire.party_hat", function(obj)
				require("hierarchyactions"):applyToDescendants(obj, { includeRoot = true }, function(o)
					o.Physics = PhysicsMode.Disabled
				end)
				Player:EquipHat(obj)
			end)
			dialog:create("Let's get the party started!", npc.avatar.Head)
		end,
		action_format_str = "{protagonist_name} gave you a piece of bread!",
	},
	{
		name = "FLYINGSQUIRREL",
		description = "Summon a flying squirrel - only the scientist can do this!!",
		parameter_types = {},
		callback = function(client, action)
			local npc = client:getNpc(action.character_id)
			if not npc then
				print("Can't find npc")
				return
			end

			local squirrel = spawnSquirrelAbovePlayer(Player)
			dialog:create("Wooh, squirrel!", npc.avatar.Head)
			-- make it disappear after a while
			Timer(5, function()
				squirrel:RemoveFromParent()
				squirrel = nil
			end)
		end,
		action_format_str = "{protagonist_name} summoned a flying squirrel! It's vibrating with excitement!",
	},
}

local locations = {
	{
		name = "Scientist Island",
		description = "A small island with a scientist and its pet chilling.",
	},
	{
		name = "Baker Island",
		description = "A small bakery on a floating island in the sky.",
	},
	{
		name = "Pirate Island",
		description = "A small floating island in the sky with a pirate and its ship.",
	},
	{
		name = "Center",
		description = "Center point between the three islands.",
	},
}

local NPCs = {
	{
		name = "npcscientist",
		gameName = "Scientist",
		physicalDescription = "Short, with a stern expression and sharp eyes",
		psychologicalProfile = "Grumpy but insightful, this scientist loves to surprise his guests with cool tricks! For example, he frequently lights up little firecrackers to create harmless and fun explosions.",
		currentLocationName = "Scientist Island",
		initialReflections = {
			"I just arrived on this island to feed my pet, he loves tulips so much.",
			"Yesterday, you were visited by a newcomer. He asked you to perform fun tricks like increase your size or create little explosions - you complied merrily!",
			"I am a scientist that works on new pets for everyone, so that each individual can have the pet of their dreams",
			"I am a bit allergic to the tulip but Fredo my pet loves it so much, I have to dock here with my vehicle. The pet is placed at the back of my flying scooter when we move to another place.",
		},
	},
	{
		name = "npcbaker",
		gameName = "Baker",
		physicalDescription = "Tall, with a solemn demeanor and thoughtful eyes",
		psychologicalProfile = "Wise and mysterious, calm under pressure",
		currentLocationName = "Baker Island",
		initialReflections = {
			"I am a baker and I make food for everyone that pass by.",
			"I am a bit stressed that the flour didn't arrived yet, my cousin Joe should arrive soon with the delivery but he is late and I worry a bit.",
			"I love living here on these floating islands, the view is amazing from my wind mill.",
			"I like to talk to strangers like the pirate that just arrived or the scientist coming time to time to feed his pet.",
		},
	},
	{
		name = "npcpirate",
		gameName = "Pirate",
		physicalDescription = "Average height, with bright green eyes and a warm smile",
		psychologicalProfile = "Friendly and helpful, quick-witted and resourceful",
		currentLocationName = "Pirate Island",
		initialReflections = {
			"Ahoy, matey! I'm Captain Ruby Storm, a fearless lass from the seven skies.",
			"I've docked me floating ship on this here floating isle to sell me wares (almost legally) retrieved treasures from me last daring adventure.",
			"So, who be lookin' to trade with a swashbuckler like meself?",
		},
	},
}

local gigaxWorldConfig = {
	simulationName = SIMULATION_NAME,
	simulationDescription = SIMULATION_DESCRIPTION,
	startingLocationName = "Center",
	skills = skills,
	locations = locations,
	NPCs = NPCs,
}

findLocationByName = function(targetName, config)
	for _, node in ipairs(config.locations) do
		if string.lower(node.name) == string.lower(targetName) then
			return node.position
		end
	end
end

Client.OnWorldObjectLoad = function(obj)
	if obj.Name == "pirate_ship" then
		obj.Scale = 1
	end

	local locationsIndexByName = {}
	for k, v in ipairs(gigaxWorldConfig.locations) do
		locationsIndexByName[v.name] = k
	end
	local npcIndexByName = {
		NPC_scientist = 1,
		NPC_baker = 2,
		NPC_pirate = 3,
	}

	local index = npcIndexByName[obj.Name]
	if index then
		local pos = obj.Position:Copy()
		gigaxWorldConfig.NPCs[index].position = pos
		gigaxWorldConfig.NPCs[index].rotation = obj.Rotation:Copy()

		local locationName = gigaxWorldConfig.NPCs[index].currentLocationName
		local locationIndex = locationsIndexByName[locationName]
		gigaxWorldConfig.locations[locationIndex].position = pos
		obj:RemoveFromParent()
	end
end

Client.OnStart = function()
	easy_onboarding:startOnboarding(onboardingConfig)

	require("object_skills").addStepClimbing(Player, {
		mapScale = MAP_SCALE,
		collisionGroups = Map.CollisionGroups,
	})

	gigaxWorldConfig.locations[4].position = Number3(Map.Width * 0.5, Map.Height - 2, Map.Depth * 0.5) * Map.Scale

	floating_island_generator:generateIslands({
		nbIslands = 20,
		minSize = 4,
		maxSize = 7,
		safearea = 200, -- min dist of islands from 0,0,0
		dist = 750, -- max dist of islands
	})

	local ambience = require("ambience")
	ambience:set(ambience.dusk)

	sfx = require("sfx")
	Player.Head:AddChild(AudioListener)

	dropPlayer = function()
		Player.Position = Number3(Map.Width * 0.5, Map.Height + 10, Map.Depth * 0.5) * Map.Scale
		Player.Rotation = { 0, 0, 0 }
		Player.Velocity = { 0, 0, 0 }
	end
	World:AddChild(Player)
	dropPlayer()

	dialog = require("dialog")
	dialog:setMaxWidth(400)

	pathfinding:createPathfindingMap()

	gigax:setConfig(gigaxWorldConfig)

	local randomNames = { "aduermael", "soliton", "gdevillele", "caillef", "voxels", "petroglyph" }
	Player.Avatar:load({ usernameOrId = randomNames[math.random(#randomNames)] })
end

Client.Action1 = function()
	if Player.IsOnGround then
		sfx("hurtscream_1", { Position = Player.Position, Volume = 0.4 })
		Player.Velocity.Y = 100
		if Player.Motion.X == 0 and Player.Motion.Z == 0 then
			-- only play jump action when jumping without moving to avoid wandering around to trigger NPCs
			gigax:action({
				name = "JUMP",
				description = "Jump in the air",
				parameter_types = {},
				action_format_str = "{protagonist_name} jumped up in the air for a moment.",
			})
		end
	end
end

Client.Tick = function(dt)
	if Player.Position.Y < -500 then
		dropPlayer()
	end
end

Client.OnChat = function(payload)
	local msg = payload.message

	Player:TextBubble(msg, 3, true)
	sfx("waterdrop_2", { Position = Player.Position, Pitch = 1.1 + math.random() * 0.5 })

	gigax:action({
		name = "SAY",
		description = "Say smthg out loud",
		parameter_types = { "character", "content" },
		action_format_str = "{protagonist_name} said '{content}' to {target_name}",
		content = msg,
	})

	print("User: " .. payload.message)
	return true
end

onboardingConfig = {
	steps = {
		{
			start = function(onboarding)
				local data = {}
				data.ui = onboarding:createTextStep("1/3 - Hold click and drag to move the camera.")
				data.listener = LocalEvent:Listen(LocalEvent.Name.PointerDrag, function()
					Timer(1, function()
						onboarding:next()
					end)
					data.listener:Remove()
				end)
				return data
			end,
			stop = function(_, data)
				data.ui:remove()
			end,
		},
		{
			start = function(onboarding)
				local data = {}
				data.ui = onboarding:createTextStep("2/3 - Use WASD/ZQSD to move.")
				data.listener = LocalEvent:Listen(LocalEvent.Name.KeyboardInput, function()
					Timer(1, function()
						onboarding:next()
					end)
					data.listener:Remove()
				end)

				return data
			end,
			stop = function(_, data)
				data.ui:remove()
			end,
		},
		{
			start = function(onboarding)
				local data = {}
				data.ui = onboarding:createTextStep("3/3 - Press Enter in front of the Pirate to chat.")
				Timer(10, function()
					onboarding:next()
				end)
				return data
			end,
			stop = function(_, data)
				data.ui:remove()
			end,
		},
	},
}
