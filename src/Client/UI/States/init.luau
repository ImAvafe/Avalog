local Avalog = script.Parent.Parent.Parent.Parent
local Fusion = require(Avalog.Parent.Fusion)

local Scope = Fusion.scoped(Fusion)

local function UnloadedService(): { [any]: any }
	return {}
end

local States = {
	Services = {
		AvatarService = UnloadedService(),
	},
	Catalog = {
		Searching = Scope:Value(false),
		SearchQuery = Scope:Value(""),
		Mode = Scope:Value(1),
		Category = Scope:Value(1),
		SubCategory = Scope:Value(1),
	},
	Avatar = {
		Data = Scope:Value(nil),
		AssetIds = Scope:Value({}),
		EquippedAssetIds = Scope:Value({}),
		EquippedBundleIds = Scope:Value({}),
		Character = Scope:Value(nil),
	},
	Checkout = {
		Loading = Scope:Value(false),
	},
	Open = Scope:Value(false),
}

return States
