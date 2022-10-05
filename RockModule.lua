--! non-strict

-- Last Updated 05/10/22 (English Dates)

--[[
		RockModule V1.0 by rsxpct
		
		Rock Modules are useful for skills, and a whole lot of things!
		I decided to make a pretty lightweight and easy to use module to support your games.
			
		HOW TO USE THIS MODULE:
		
			At the top of where you want to use this module do.
			
			local RockModule = require(ModuleDirectory)
			
			then where further down use.
			
			local Rocks = RockModule.new(Player)
			
			then wherever you want to use it use the following functions:
			
		FOR THE GROUND RING READ BELOW
		
			Rocks:GroundRing(Position, Size, Distance, RayFilter, Data, DespawnTime)
			
			Position = Center Position of the ring (Vector3)
			Size = Size of each rock (Vector3)
			Distance = How big the rock circle should be.
			RayFilter = What should the raycast blacklist. (Table)
			Data = A Table of things. Which are:
			
			{
				Ice = Should the rocks be ice. (Boolean)
				OnFire = Should the rocks be on fire. (Boolean)
				MaxRocks = Max amount of rocks. (Number)
			
			}
			
			Then the final argument, DespawnTime. How long the rocks should last. (Number)
			
		FOR THE BLOCK EXPLOSION READ BELOW
		
			Rocks:BlockExplosion(TargetCFrame, MinimumSize, MaxmimumSize, MinimumAmount, MaxmimumAmount, OnFire)
			
			TargetCFrame = Where the rocks should explode from. (CFrame)
			MinimumSize = Minimum Size of each rock. (Number)
			MaximumSize = Maximum Size of each rock. (Number)
			MinimumAmount = Minimum Amount of rocks to explode. (Number)
			MaxmimumAmount = Maximum Amount of rocks to explode (Number)

			Then the final argument, OnFire. Should the rocks be on fire. (Boolean)
			
--]]

local TweenService = game:GetService("TweenService")

local PartCache = require(script.Parent.PartCache)

local CacheFolder
if not workspace.Debris:FindFirstChild("Parts") then
	CacheFolder = Instance.new("Folder")
	CacheFolder.Name = "PartCacheRockModule"
	CacheFolder.Parent = CacheFolder
else
	CacheFolder = workspace.Debris.Parts
end

local RockModule = {}
RockModule.__index = RockModule

function RockModule.new(Player: Player)
	local self = setmetatable({}, RockModule)
	
	self.Player = Player
	
	self._PartCache = PartCache.new(Instance.new("Part"), 200, CacheFolder)
	
	return self
end

function RockModule:BlockExplosion(TargetCFrame: CFrame, MinimumSize: number, MaxmimumSize: number, MinimumAmount: number, MaxmimumAmount: number, OnFire: boolean)
	local RandomNumber = Random.new(math.random(-20000, 20000))

	for _ = 1, math.random(MinimumAmount, MaxmimumAmount) do
		local Size = Random:NextNumber(MinimumSize, MaxmimumSize)

		local origin = TargetCFrame.Position
		local direction = Vector3.new(0,-100,0)

		local Params = RaycastParams.new()
		Params.FilterDescendantsInstances = {workspace.Debris}
		Params.FilterType = Enum.RaycastFilterType.Blacklist

		local raycastResult = workspace:Raycast(origin, direction, Params)

		local Raycast = Ray.new(origin + Vector3.new(0, 3, 0), Vector3.new(0, -50, 0))
		local Hit, Vector2Position, surfaceNormal = workspace:FindPartOnRayWithIgnoreList(Raycast, {workspace.Debris})

		if Hit then
			local HitPart = Hit

			local Effect = self._PartCache:GetPart()
			Effect.Transparency = 0
			Effect.Anchored = false

			Effect.Material = HitPart.Material
			Effect.Color = HitPart.Color
			Effect.Size = Vector3.new(Size,Size,Size)

			Effect.CFrame = TargetCFrame * CFrame.Angles(math.rad(math.random(-180, 180)), math.rad(math.random(15, 165)), math.rad(math.random(-180, 180)))

			Effect.CanCollide = true
			Effect.CanTouch = false
			Effect.CanQuery = false

			if OnFire then
				local FireVfx1 = script.OnFire.OnFire:Clone()
				local FireVfx2 = script.OnFire.OnFireWisps:Clone()
				local FireVfx3 = script.OnFire.OnFireSparks:Clone()
				local FireLight = script.OnFire.PointLight:Clone()

				FireVfx1.Parent = Effect
				FireVfx2.Parent = Effect
				FireVfx3.Parent = Effect
				FireLight.Parent = Effect

				task.delay(2, function()
					TweenService:Create(FireLight, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0})
					FireVfx1.Enabled = false
					FireVfx2.Enabled = false
					FireVfx3.Enabled = false
				end)

				game.Debris:AddItem(FireVfx1, 3.5)
				game.Debris:AddItem(FireVfx2, 3.5)
				game.Debris:AddItem(FireVfx3, 3.5)
				game.Debris:AddItem(FireLight, 3.5)
			end

			local db = false

			task.delay(2.9, function()
				local EndTween = TweenService:Create(Effect, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Size = Vector3.new(0,0,0)}):Play()
			end)

			local EffectVelocity = Instance.new("BodyVelocity", Effect)
			EffectVelocity.MaxForce = Vector3.new(0.5, 2, 0.5) * 100000;
			EffectVelocity.Velocity = Vector3.new(0.5, 2, 0.5) * Effect.CFrame.LookVector * math.random(50, 70)

			game.Debris:AddItem(EffectVelocity, 0.3)
			task.delay(3.5, function()
				self._PartCache:ReturnPart(Effect)
			end)
		end
	end
end

function RockModule:GroundRing(Position: Vector3, Size: Vector3, Distance: number, RayFilter: RaycastParams, Data, DespawnTime: number)
	local Size = Size or Vector3.new(1.5, 1.5, 1.5)
	local Position = Position
	local DespawnTime = DespawnTime or 3
	
	local Ice = Data.Ice or false
	local OnFire = Data.OnFire or false
	
	local MaxRocks = Data.MaxRocks or 20
	
	local Angle = 30
	local OtherAngle = 360/MaxRocks
	
	local Parameters = RaycastParams.new()
	Parameters.FilterType = Enum.RaycastFilterType.Blacklist
	Parameters.FilterDescendantsInstances = RayFilter or {self.Player.Character, CacheFolder, workspace.Debris}
	
	local VfxPart = Instance.new("Part")
	VfxPart.Transparency = 1
	VfxPart.Anchored = true
	VfxPart.Position = Position
	VfxPart.Size = Vector3.new()
	
	VfxPart.Parent = workspace.Debris
	
	local Raycast = workspace:Raycast(Position + Vector3.new(0, 1, 0), Vector3.new(0, -25, 0), Parameters)
	if Raycast then
		local DustParticles = script.Dust:Clone()
		DustParticles.Color = ColorSequence.new(Raycast.Instance.Color)

		DustParticles.Parent = VfxPart
		DustParticles:Emit(DustParticles:GetAttribute("EmitCount"))
	end
	
	game.Debris:AddItem(VfxPart, 3)
	
	local function OuterParts()
		for i = 1, MaxRocks do
			local cf = CFrame.new(Position)
			local newCF = cf * CFrame.fromEulerAnglesXYZ(0, math.rad(Angle), 0) * CFrame.new(Distance/2 + Distance/2.7, 10, 0)
			local ray = workspace:Raycast(newCF.Position, Vector3.new(0, -20, 0), Parameters)
			Angle += OtherAngle
			if ray then
				local Part = self._PartCache:GetPart()
				local Back = self._PartCache:GetPart()

				Part.CFrame = CFrame.new(ray.Position - Vector3.new(0, 0.5, 0), Position) * CFrame.fromEulerAnglesXYZ(Random:NextNumber(-.25, .5), Random:NextNumber(-.25, .25), Random:NextNumber(-.25, .25))
				Part.Size = Vector3.new(Size.X * 1.3, Size.Y/1.4, Size.Z * 1.3) * Random:NextNumber(1, 1.5)

				Back.Size = Vector3.new(Part.Size.X * 1.01, Part.Size.Y * 0.25, Part.Size.Z * 1.01)
				Back.CFrame = Part.CFrame * CFrame.new(0, Part.Size.Y/2 - Back.Size.Y / 2.1, 0)

				Part.Parent = CacheFolder
				Back.Parent = CacheFolder

				if ray.Instance.Material == Enum.Material.Concrete or ray.Instance.Material == Enum.Material.Air or ray.Instance.Material == Enum.Material.Wood or ray.Instance.Material == Enum.Material.Neon or ray.Instance.Material == Enum.Material.WoodPlanks then
					Part.Material = ray.Instance.Material	
					Back.Material = ray.Instance.Material	
				else
					Part.Material = Enum.Material.Concrete
					Back.Material = ray.Instance.Material	
				end

				Part.BrickColor = BrickColor.new("Dark grey")
				Part.Anchored = true
				Part.CanTouch = false
				Part.CanCollide = false

				Back.BrickColor = ray.Instance.BrickColor
				Back.Anchored = true
				Back.CanTouch = false
				Back.CanCollide = false

				if Ice then
					Part.BrickColor = BrickColor.new("Pastel light blue")
					Back.BrickColor = BrickColor.new("Lily white")
					Part.Material = Enum.Material.Ice
					Back.Material = Enum.Material.Sand
				end

				task.delay(DespawnTime, function()
					TweenService:Create(Part,TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{Size = Vector3.new(.01, .01, .01)}):Play()
					TweenService:Create(Back,TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{Size = Vector3.new(.01, .01, .01), CFrame = Part.CFrame * CFrame.new(0, Part.Size.Y/2 - Part.Size.Y / 2.1, 0)}):Play()

					task.delay(0.6, function()
						self._PartCache:ReturnPart(Part)
						self._PartCache:ReturnPart(Back)
					end)
				end)
			end		
		end
	end
	
	local function InnerParts()
		for i = 1, MaxRocks do
			local cf = CFrame.new(Position)
			local newCF = cf * CFrame.fromEulerAnglesXYZ(0, math.rad(Angle), 0) * CFrame.new(Distance/2 + Distance/10, 10, 0)
			local ray = game.Workspace:Raycast(newCF.Position, Vector3.new(0, -20, 0), Parameters)
			Angle += OtherAngle
			if ray then
				local Part = self._PartCache:GetPart()
				local Back = self._PartCache:GetPart()

				Part.CFrame = CFrame.new(ray.Position - Vector3.new(0, Size.Y * 0.4, 0), Position) * CFrame.fromEulerAnglesXYZ(Random:NextNumber(-1,-0.3),Random:NextNumber(-0.15,0.15),Random:NextNumber(-.15,.15))
				Part.Size = Vector3.new(Size.X * 1.3, Size.Y * 0.7, Size.Z * 1.3) * Random:NextNumber(1, 1.5)

				Back.Size = Vector3.new(Part.Size.X * 1.01, Part.Size.Y * 0.25, Part.Size.Z * 1.01)
				Back.CFrame = Part.CFrame * CFrame.new(0, Part.Size.Y/2 - Back.Size.Y / 2.1, 0)

				Part.Parent = CacheFolder
				Back.Parent = CacheFolder

				if ray.Instance.Material == Enum.Material.Concrete or ray.Instance.Material == Enum.Material.Air or ray.Instance.Material == Enum.Material.Wood or ray.Instance.Material == Enum.Material.Neon or ray.Instance.Material == Enum.Material.WoodPlanks then
					Part.Material = ray.Instance.Material	
					Back.Material = ray.Instance.Material	
				else
					Part.Material = Enum.Material.Concrete --ray.Instance.Material	
					Back.Material = ray.Instance.Material	
				end

				Part.BrickColor = BrickColor.new("Dark grey") --ray.Instance.BrickColor
				Part.Anchored = true
				Part.CanTouch = false
				Part.CanCollide = false

				Back.BrickColor = ray.Instance.BrickColor
				Back.Anchored = true
				Back.CanTouch = false
				Back.CanCollide = false

				if Ice then
					Part.BrickColor = BrickColor.new("Pastel light blue")
					Part.BrickColor = BrickColor.new("Lily white")
					Part.Material = Enum.Material.Ice
					Back.Material = Enum.Material.Sand
				end

				task.delay(DespawnTime, function()
					TweenService:Create(Part,TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{Size = Vector3.new(.01, .01, .01)}):Play()
					TweenService:Create(Back,TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),{Size = Vector3.new(.01, .01, .01), CFrame = Part.CFrame * CFrame.new(0, Part.Size.Y/2 - Part.Size.Y / 2.1, 0)}):Play()

					task.delay(0.6, function()
						self._PartCache:ReturnPart(Part)
						self._PartCache:ReturnPart(Back)
					end)
				end)
			end		
		end
	end
	
	OuterParts()
	InnerParts()
end

function RockModule:Release()
	self._PartCache:Dispose()
	self._PartCache = nil
	
	self._Player = nil
end

return RockModule
