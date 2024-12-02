local Avalog = script.Parent.Parent.Parent.Parent
local Signal = require(Avalog.Parent.Signal)
local DeepCopy = require(Avalog.SourceCode.Shared.Utils.DeepCopy)

export type AccessorySpec = {
	Order: number?,
	AssetId: number,
	AccessoryType: Enum.AccessoryType,
	Puffiness: number?,
}
export type EquippedEmote = {
	Name: string,
	Slot: number,
}
export type Data = {
	Accessories: { AccessorySpec },
	Emotes: {
		[string]: { number },
	},
	EquippedEmotes: { EquippedEmote },
	Face: number,
	Scale: {
		BodyType: number,
		Depth: number,
		Head: number,
		Height: number,
		Proportion: number,
		Width: number,
	},
	Animations: {
		Walk: number,
		Run: number,
		Fall: number,
		Climb: number,
		Swim: number,
		Idle: number,
		Mood: number,
		Jump: number,
	},
	BodyParts: {
		Head: number,
		Torso: number,
		LeftArm: number,
		RightArm: number,
		LeftLeg: number,
		RightLeg: number,
	},
	BodyPartColors: {
		Head: Color3,
		Torso: Color3,
		LeftArm: Color3,
		RightArm: Color3,
		LeftLeg: Color3,
		RightLeg: Color3,
	},
	Clothing: {
		Shirt: number,
		TShirt: number,
		Pants: number,
	},
}

local HumanoidDescriber = {
	Data = {
		Accessories = {},
		Emotes = {},
		Face = 0,
		Scale = {
			BodyType = 0,
			Depth = 0,
			Head = 0,
			Height = 0,
			Proportion = 0,
			Width = 0,
		},
		Animations = {
			Walk = 0,
			Run = 0,
			Fall = 0,
			Climb = 0,
			Swim = 0,
			Idle = 0,
			Mood = 0,
			Jump = 0,
		},
		BodyParts = {
			Head = 0,
			Torso = 0,
			LeftArm = 0,
			RightArm = 0,
			LeftLeg = 0,
			RightLeg = 0,
		},
		BodyPartColors = {
			Head = Color3.fromRGB(0, 0, 0),
			Torso = Color3.fromRGB(0, 0, 0),
			LeftArm = Color3.fromRGB(0, 0, 0),
			RightArm = Color3.fromRGB(0, 0, 0),
			LeftLeg = Color3.fromRGB(0, 0, 0),
			RightLeg = Color3.fromRGB(0, 0, 0),
		},
		Clothing = {
			Shirt = 0,
			TShirt = 0,
			Pants = 0,
		},
	},
	HumanoidDescription = Instance.new("HumanoidDescription"),
}

function HumanoidDescriber:SetEmoteEquipped(Name: string, Equipped: boolean)
	self:UpdateData(function(Data)
		local ExistingIndex = self:GetEquippedEmote(Name)

		if Equipped then
			if not ExistingIndex then
				if #Data.EquippedEmotes >= 8 then
					table.remove(Data.EquippedEmotes, #Data.EquippedEmotes)
				end

				table.insert(Data.EquippedEmotes, {
					Name = Name,
					Slot = #Data.EquippedEmotes + 1,
				})
			end
		else
			if ExistingIndex then
				table.remove(Data.EquippedEmotes, ExistingIndex)
			end
		end

		return Data
	end)
end

function HumanoidDescriber:GetEquippedEmote(Name: string): (number?, EquippedEmote?)
	local Data = self:GetData()

	for Index, Emote in ipairs(Data.EquippedEmotes) do
		if Emote.Name == Name then
			return Index, Emote
		end
	end

	return nil
end

function HumanoidDescriber:SetEmote(Name: string, Emote: { number } | nil)
	self:UpdateData(function(Data)
		Data.Emotes[Name] = Emote
		return Data
	end)
end

function HumanoidDescriber:GetEmote(Name: string)
	local Data = self:GetData()

	for EmoteName, Emote in pairs(Data.Emotes) do
		if EmoteName == Name then
			return Emote
		end
	end

	return nil
end

function HumanoidDescriber:ToggleAccessory(Accessory: AccessorySpec)
	if self:GetAccessory(Accessory.AssetId) then
		self:RemoveAccessory(Accessory.AssetId)
	else
		self:AddAccessory(Accessory)
	end
end

function HumanoidDescriber:AddAccessory(Accessory: AccessorySpec)
	local AccessoryIndex = self:GetAccessory(Accessory.AssetId)

	if AccessoryIndex == nil then
		self:UpdateData(function(Data)
			table.insert(Data.Accessories, Accessory)
			return Data
		end)
	end
end

function HumanoidDescriber:RemoveAccessory(AssetId: number)
	local AccessoryIndex = self:GetAccessory(AssetId)

	if AccessoryIndex ~= nil then
		self:UpdateData(function(Data)
			table.remove(Data.Accessories, AccessoryIndex)
			return Data
		end)
	end
end

function HumanoidDescriber:GetAccessory(AssetId: number): (number?, AccessorySpec?)
	local Data = self:GetData()

	for Index, Accessory: AccessorySpec in ipairs(Data.Accessories) do
		if Accessory.AssetId == AssetId then
			return Index, Accessory
		end
	end

	return nil
end

function HumanoidDescriber:ReadFromDescription(HumanoidDescription: HumanoidDescription)
	self.HumanoidDescription = HumanoidDescription

	local NewData: Data = {
		Face = self.HumanoidDescription.Face,
		Accessories = self.HumanoidDescription:GetAccessories(true),
		Emotes = self.HumanoidDescription:GetEmotes(),
		EquippedEmotes = self.HumanoidDescription:GetEquippedEmotes(),
		Scale = {
			BodyType = self.HumanoidDescription.BodyTypeScale,
			Depth = self.HumanoidDescription.DepthScale,
			Head = self.HumanoidDescription.HeadScale,
			Height = self.HumanoidDescription.HeightScale,
			Proportion = self.HumanoidDescription.ProportionScale,
			Width = self.HumanoidDescription.WidthScale,
		},
		BodyParts = {
			Head = self.HumanoidDescription.Head,
			Torso = self.HumanoidDescription.Torso,
			LeftLeg = self.HumanoidDescription.LeftLeg,
			RightLeg = self.HumanoidDescription.RightLeg,
			LeftArm = self.HumanoidDescription.LeftArm,
			RightArm = self.HumanoidDescription.RightArm,
		},
		Animations = {
			Idle = self.HumanoidDescription.IdleAnimation,
			Walk = self.HumanoidDescription.WalkAnimation,
			Run = self.HumanoidDescription.RunAnimation,
			Fall = self.HumanoidDescription.FallAnimation,
			Jump = self.HumanoidDescription.JumpAnimation,
			Mood = self.HumanoidDescription.MoodAnimation,
			Swim = self.HumanoidDescription.SwimAnimation,
		},
		Clothing = {
			Shirt = self.HumanoidDescription.Shirt,
			TShirt = self.HumanoidDescription.GraphicTShirt,
			Pants = self.HumanoidDescription.Pants,
		},
		BodyPartColors = {
			HeadColor = self.HumanoidDescription.HeadColor,
			TorsoColor = self.HumanoidDescription.TorsoColor,
			LeftLegColor = self.HumanoidDescription.LeftLegColor,
			RightLegColor = self.HumanoidDescription.RightLegColor,
			LeftArmColor = self.HumanoidDescription.LeftArmColor,
			RightArmColor = self.HumanoidDescription.RightArmColor,
		},
	}

	self:UpdateData(function()
		return NewData
	end, false)
end

function HumanoidDescriber:_UpdateHumanoidDescription()
	local Data = self:GetData()
	local Properties = {
		Face = Data.Face,

		BodyTypeScale = Data.Scale.BodyType,
		DepthScale = Data.Scale.Depth,
		HeadScale = Data.Scale.Head,
		HeightScale = Data.Scale.Height,
		ProportionScale = Data.Scale.Proportion,
		WidthScale = Data.Scale.Width,

		WalkAnimation = Data.Animations.Walk,
		RunAnimation = Data.Animations.Run,
		FallAnimation = Data.Animations.Fall,
		ClimbAnimation = Data.Animations.Climb,
		SwimAnimation = Data.Animations.Swim,
		IdleAnimation = Data.Animations.Idle,
		MoodAnimation = Data.Animations.Mood,
		JumpAnimation = Data.Animations.Jump,

		Head = Data.BodyParts.Head,
		Torso = Data.BodyParts.Torso,
		LeftArm = Data.BodyParts.LeftArm,
		RightArm = Data.BodyParts.RightArm,
		LeftLeg = Data.BodyParts.LeftLeg,
		RightLeg = Data.BodyParts.RightLeg,

		HeadColor = Data.BodyPartColors.Head,
		TorsoColor = Data.BodyPartColors.Torso,
		LeftArmColor = Data.BodyPartColors.LeftArm,
		RightArmColor = Data.BodyPartColors.RightArm,
		LeftLegColor = Data.BodyPartColors.LeftLeg,
		RightLegColor = Data.BodyPartColors.RightLeg,

		Shirt = Data.Clothing.Shirt,
		GraphicTShirt = Data.Clothing.TShirt,
		Pants = Data.Clothing.Pants,
	}

	for Name, Value in pairs(Properties) do
		if self.HumanoidDescription[Name] ~= Value then
			self.HumanoidDescription[Name] = Value
		end
	end

	self.HumanoidDescription:SetAccessories(Data.Accessories, true)
	self.HumanoidDescription:SetEmotes(Data.Emotes)
	self.HumanoidDescription:SetEquippedEmotes(Data.EquippedEmotes)
end

function HumanoidDescriber:UpdateData(ModifierCallback: (Data) -> Data, UpdateDescription: boolean?)
	if UpdateDescription == nil then
		UpdateDescription = true
	end

	local OldData = self:GetData()
	local NewData = ModifierCallback(self:GetData())

	if NewData ~= nil then
		self.Data = NewData

		if UpdateDescription then
			self:_UpdateHumanoidDescription()
		end

		self.Updated:Fire(OldData, NewData)
	else
		assert(false, "Data was not returned.")
	end
end

function HumanoidDescriber:GetData(): Data
	return DeepCopy(self.Data)
end

function HumanoidDescriber:Destroy()
	self.Updated:Destroy()
end

function HumanoidDescriber.new(HumanoidDescription: HumanoidDescription)
	local self = table.clone(HumanoidDescriber)
	self.Updated = Signal.new()

	self:ReadFromDescription(HumanoidDescription)

	return self
end

return HumanoidDescriber
