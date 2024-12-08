local MarketplaceService = game:GetService("MarketplaceService")
local Avalog = script.Parent.Parent.Parent.Parent
local Future = require(Avalog.Parent.Future)
local RateLimit = require(Avalog.Parent.RateLimit)
local HumanoidDescriber = require(Avalog.SourceCode.Shared.Utils.HumanoidDescriber)

local RATE_LIMITS = {
	Update = RateLimit(1, 1),
	BulkPurchaseItems = RateLimit(1, 2),
}

local AvatarService = {
	Name = script.Name,
	Client = {},

	Avatars = {},
}

function AvatarService.Client:BulkPurchaseItems(Player: Player, Items: { any })
	if not RATE_LIMITS.BulkPurchaseItems(Player.UserId) then
		return
	end

	return AvatarService:BulkPurchaseItems(Player, Items)
end

function AvatarService.Client:Update(Player: Player, Data: HumanoidDescriber.Data)
	if not RATE_LIMITS.Update(Player.UserId) then
		return
	end

	return AvatarService:Update(Player, Data)
end

function AvatarService:BulkPurchaseItems(Player: Player, Items: { any })
	return Future.Try(function()
		return MarketplaceService:PromptBulkPurchase(Player, Items, {})
	end):Await()
end

function AvatarService:Update(Player: Player, Data: HumanoidDescriber.Data)
	local _, Humanoid, HumanoidDescription = self:GetCharacterObjects(Player)
	if Humanoid and HumanoidDescription then
		local HumanoidDescriberObject = HumanoidDescriber(HumanoidDescription)

		HumanoidDescriberObject:UpdateData(function()
			return Data
		end)

		self:Apply(Player, HumanoidDescription):Await()

		HumanoidDescriberObject:Destroy()
	end
end

function AvatarService:Apply(Player: Player, HumanoidDescription: HumanoidDescription)
	local Character = Player.Character

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Future.Try(function()
				Humanoid:ApplyDescriptionReset(HumanoidDescription)
			end)
		end
	end

	return false
end

function AvatarService:GetCharacterObjects(Player: Player): (Model?, Humanoid?, HumanoidDescription?)
	local Character = Player.Character

	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			return Character, Humanoid, Humanoid:FindFirstChildOfClass("HumanoidDescription")
		end
	end

	return nil
end

function AvatarService:KnitStart() end

function AvatarService:KnitInit() end

return AvatarService
