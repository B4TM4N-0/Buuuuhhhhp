local Library do

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
    
gethui = gethui or function()
	return cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
end

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local IsMobile = UserInputService.TouchEnabled or false


Library = {
    Theme =  { },
    ToClean = { },

    MenuKeybind = tostring(Enum.KeyCode.Insert), 

    Flags = { },

    Tween = {
        Time = 0.3,
        Style = Enum.EasingStyle.Quad,
        Direction = Enum.EasingDirection.Out
    },

    FadeSpeed = 0.2,

    Folders = {
        Directory = "Xyzu",
        Configs = "Xyzu/Configs",
    },

    -- Ignore below
    Pages = { },
    Sections = { },

    Connections = { },
    Threads = { },

    ThemeMap = { },
    ThemeItems = { },

    OpenFrames = { },

    SetFlags = { },

    UnnamedConnections = 0,
    UnnamedFlags = 0,

    Holder = nil,
    NotifHolder = nil,
    UnusedHolder = nil,
}

Library.__index = Library
Library.Sections.__index = Library.Sections
Library.Pages.__index = Library.Pages

local LucideIcon 
local IconLoaded, result = pcall(function()
	LucideIcon = loadstring(game:HttpGet("https://raw.githubusercontent.com/xyzuCode/Icon/refs/heads/main/lucide/dist/Icons.lua"))()
end)

if IconLoaded then 
warn(`Successfully loaded the icons {result}`) 
end

local Themes = {
	["Preset"] = {
		Primary     = Color3.fromRGB(245, 230, 200), -- hover button
		Background      = Color3.fromRGB(18, 18, 18),   -- 0dp
		Surface         = Color3.fromRGB(28, 28, 30),   -- cards
		SurfaceAlt      = Color3.fromRGB(36, 36, 40),   -- elevated surface
		SurfaceHover    = Color3.fromRGB(44, 44, 48),   -- hover / active
		
		PrimaryText     = Color3.fromRGB(245, 245, 245),
		SecondaryText   = Color3.fromRGB(170, 170, 175),
		MutedText       = Color3.fromRGB(120, 120, 125),
		
		Accent          = Color3.fromRGB(138, 180, 248),
		AccentSoft      = Color3.fromRGB(90, 120, 180),
		
		Divider         = Color3.fromRGB(60, 60, 65),
		Border          = Color3.fromRGB(55, 55, 60),
		
		Success         = Color3.fromRGB(76, 175, 80),
		Warning         = Color3.fromRGB(255, 193, 7),
		Danger          = Color3.fromRGB(244, 67, 54),
		
		InputBackground = Color3.fromRGB(24, 24, 26),
		CardBackground  = Color3.fromRGB(30, 30, 32),
	}
}

Library.Theme = table.clone(Themes["Preset"])

for Index, Value in pairs(Library.Folders) do 
    if not isfolder(Value) then
        makefolder(Value)
    end
end

local Tween = { } 
do
Tween.__index = Tween

function Tween.Create(self, Item, Info, Goal, IsRawItem)
    if typeof(Item) == "Instance" then
        Item = Item
    else
        Item = Item.Instance
    end

    Info = Info or TweenInfo.new(
        Library.Tween.Time,
        Library.Tween.Style,
        Library.Tween.Direction
    )

    local NewTween = {
        Tween = TweenService:Create(Item, Info, Goal),
        Info = Info,
        Goal = Goal,
        Item = Item
    }

    NewTween.Tween:Play()

    setmetatable(NewTween, Tween)

    return NewTween
end

function Tween.GetProperty(self, Item)
    Item = Item or self.Item 

    if Item:IsA("Frame") then
        return { "BackgroundTransparency" }
    elseif Item:IsA("TextLabel") or Item:IsA("TextButton") then
        return { "TextTransparency", "BackgroundTransparency" }
    elseif Item:IsA("ImageLabel") or Item:IsA("ImageButton") then
        return { "BackgroundTransparency", "ImageTransparency" }
    elseif Item:IsA("ScrollingFrame") then
        return { "BackgroundTransparency", "ScrollBarImageTransparency" }
    elseif Item:IsA("TextBox") then
        return { "TextTransparency", "BackgroundTransparency" }
    elseif Item:IsA("UIStroke") then 
        return { "Transparency" }
    end
end

function Tween.FadeItem(self, Item, Property, Visibility, Speed)
    local Item = Item or self.Item 

    local OldTransparency = Item[Property]
    Item[Property] = Visibility and 1 or OldTransparency

    local NewTween = Tween:Create(Item, TweenInfo.new(Speed or Library.Tween.Time, Library.Tween.Style, Library.Tween.Direction), {
        [Property] = Visibility and OldTransparency or 1
    }, true)

    Library:Connect(NewTween.Tween.Completed, function()
        if not Visibility then 
            task.wait()
            Item[Property] = OldTransparency
        end
    end)

    return NewTween
end
end

local Instances = { }
Instances.__index = Instances

function Instances.Create(self, Class, Properties)
    local NewItem = {
        Instance = Instance.new(Class),
        Properties = Properties,
        Class = Class
    }

    setmetatable(NewItem, Instances)

    for Property, Value in pairs(NewItem.Properties) do
        NewItem.Instance[Property] = Value
    end

    return NewItem
end

function Instances.FadeItem(self, Visibility, Speed)
    local Item = self.Instance

    if Visibility == true then 
        Item.Visible = true
    end

    local Descendants = Item:GetDescendants()
    table.insert(Descendants, Item)

    local NewTween

    for Index, Value in ipairs(Descendants) do 
        local TransparencyProperty = Tween:GetProperty(Value)

        if not TransparencyProperty then 
            continue
        end

        if type(TransparencyProperty) == "table" then 
            for _, Property in ipairs(TransparencyProperty) do 
                NewTween = Tween:FadeItem(Value, Property, not Visibility, Speed)
            end
        else
            NewTween = Tween:FadeItem(Value, TransparencyProperty, not Visibility, Speed)
        end
    end
end

function Instances.Connect(self, Event, Callback, Name)
    if not self.Instance then 
        return
    end

    if not self.Instance[Event] then 
        return
    end

    if IsMobile then
        if Event == "MouseButton1Down" or Event == "MouseButton1Click" then 
            Event = "TouchTap"
        elseif Event == "MouseButton2Down" or Event == "MouseButton2Click" then 
            Event = "TouchLongPress"
        end
    end

    return Library:Connect(self.Instance[Event], Callback, Name)
end

function Instances.Tween(self, Info, Goal)
    if not self.Instance then 
        return
    end

    return Tween:Create(self, Info, Goal)
end

function Instances.Disconnect(self, Name)
    if not self.Instance then 
        return
    end

    return Library:Disconnect(Name)
end



Library.Folder = Instances:Create("Folder", {
	Parent = gethui(),
    Name = "\0",
})

Library.UnusedHolder = Instances:Create("Folder", {
	Parent = Library.Folder.Instance,
	Name = "Unused",
})

Library.Holder = Instances:Create("ScreenGui", {
	Parent = Library.Folder.Instance,
    Name = "main",
    ZIndexBehavior = Enum.ZIndexBehavior.Global,
    ResetOnSpawn   = false,
})

function Library.Round(self, Number, Float)
    local Multiplier = 1 / (Float or 1)
    return math.floor(Number * Multiplier) / Multiplier
end

function Library.Thread(self, Function)
    local NewThread = coroutine.create(Function)
    
    coroutine.wrap(function()
        coroutine.resume(NewThread)
    end)()

    table.insert(self.Threads, NewThread)
    return NewThread
end

function Library.SafeCall(self, Function, ...)
    local Arguments = { ... }
    local Success, Result = pcall(Function, unpack(Arguments))

    if not Success then
        warn(Result)
        return false
    end

    return Success
end

function Library.Connect(self, Event, Callback, Name)
    Name = Name or string.format("connection_number_%s_%s", self.UnnamedConnections + 1, HttpService:GenerateGUID(false))

    local NewConnection = {
        Event = Event,
        Callback = Callback,
        Name = Name,
        Connection = nil
    }

    Library:Thread(function()
        NewConnection.Connection = Event:Connect(Callback)
    end)

    table.insert(self.Connections, NewConnection)
    self.UnnamedConnections = self.UnnamedConnections + 1
    return NewConnection
end

function Library.Disconnect(self, Name)
    for _, Connection in ipairs(self.Connections) do 
        if Connection.Name == Name then
            Connection.Connection:Disconnect()
            break
        end
    end
end

Library.NextFlag = function(self)
    local FlagNumber = self.UnnamedFlags + 1
    return StringFormat("flag_number_%s_%s", FlagNumber, HttpService:GenerateGUID(false))
end

Library.IsMouseOverFrame = function(self, Frame)
    Frame = Frame.Instance    
    local MousePosition = Vector2.new(Mouse.X, Mouse.Y)
    return MousePosition.X >= Frame.AbsolutePosition.X and MousePosition.X <= Frame.AbsolutePosition.X + Frame.AbsoluteSize.X and MousePosition.Y >= Frame.AbsolutePosition.Y and MousePosition.Y <= Frame.AbsolutePosition.Y + Frame.AbsoluteSize.Y
end

function Library.Sanitize(tbl)
    local oldtbl = tbl or {}
    local newtbl = {}
    local formattedtbl = {}

    for option, v in next, oldtbl do
        newtbl[option:lower()] = v
    end

    setmetatable(formattedtbl, {
        __newindex = function(t, k, v)
            rawset(newtbl, k:lower(), v)
        end,
        __index = function(t, k)
            return newtbl[k:lower()]
        end,
    })

    return formattedtbl
end

Library.CompareVectors = function(self, PointA, PointB)
    return (PointA.X < PointB.X) or (PointA.Y < PointB.Y)
end

Library.IsClipped = function(self, Object, Column)
    local Parent = Column
    
    local BoundryTop = Parent.AbsolutePosition
    local BoundryBottom = BoundryTop + Parent.AbsoluteSize

    local Top = Object.AbsolutePosition
    local Bottom = Top + Object.AbsoluteSize 

    return Library:CompareVectors(Top, BoundryTop) or Library:CompareVectors(BoundryBottom, Bottom)
end

function Library:ResolvePlacement(Trigger, Height)
    local ScreenSize = workspace.CurrentCamera.ViewportSize

    local TriggerPos = Trigger.AbsolutePosition
    local TriggerSize = Trigger.AbsoluteSize

    local DownBottom = TriggerPos.Y + TriggerSize.Y + Height + 5

    if DownBottom > ScreenSize.Y then
        return "Up"
    else
        return "Down"
    end
end
    
local function HoverTween(frame, targets, info)
    info = info or TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    frame.MouseEnter:Connect(function()
        for _, target in ipairs(targets) do
            target[1]:Tween(info, target[2])
        end
    end)

    frame.MouseLeave:Connect(function()
        for _, target in ipairs(targets) do
            target[1]:Tween(info, target[3])
        end
    end)
end

function Library:ResolveImage(value)
	if type(value) == "number" then
		return "rbxassetid://" .. value
	end

	if type(value) == "string" then
		if tonumber(value) then
			return "rbxassetid://" .. value
		end

		if LucideIcon[value] then
			return LucideIcon[value]
		end
	end

	return LucideIcon["house"]
end

Library.CreateColorpicker = function(self, Data)
    local Colorpicker = {
        Flag = Data.Flag,

        Hue = 0,
        Saturation = 0,
        Value = 0,

        Alpha = 0,

        Color = Color3.fromRGB(0, 0, 0),
        HexValue = "#000000",

        SavedColors = { },

        IsOpen = false 
    }

    local Items = { }
        Items["ColorpickerButton"] = Instances:Create("TextButton", {
            Parent = Data.Parent.Instance,
            Name = "\0",
            FontFace = Library.Font,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            Text = "",
            AutoButtonColor = false,
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 100, 0, 20),
            ZIndex = 5,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        })
        
        Items["Color"] = Instances:Create("Frame", {
            Parent = Items["ColorpickerButton"].Instance,
            Name = "\0",
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(0, 0, 0, 2),
            ZIndex = 5,
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(124, 163, 255)
        })
        
        Instances:Create("UICorner", {
            Parent = Items["Color"].Instance,
            Name = "\0",
            CornerRadius = UDim.new(1, 0)
        })
        
        Items["Text"] = Instances:Create("TextLabel", {
            Parent = Items["ColorpickerButton"].Instance,
            Name = "\0",
            TextColor3 = Color3.fromRGB(240, 240, 240),
            Text = "#7842ff",
            AutomaticSize = Enum.AutomaticSize.X,
            Size = UDim2.new(0, 0, 0, 15),
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 25, 0, 2),
            BorderSizePixel = 0,
            ZIndex = 5,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        })  
        
    Items["ColorPicker"] = Instances:Create("Frame", {
		Name = "ColorPicker",
		Size = UDim2.new(0, 250, 0, 200),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(22,22,22),
		ZIndex = 6,
		Active = true,
		BackgroundTransparency = 0,
		Parent = Library.UnusedHolder.Instance,
	})
	
	Instances:Create("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = Items["ColorPicker"].Instance,
	})
	
	Instances:Create("UIPadding", {
		PaddingTop    = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
		PaddingLeft   = UDim.new(0, 10),
		PaddingRight  = UDim.new(0, 10),
		Parent = Items["ColorPicker"].Instance,
	})
	
	Instances:Create("UIListLayout", {
		Name = "list",
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Top,
		Parent = Items["ColorPicker"].Instance,
	})
	
	Items["ColorFrame"] = Instances:Create("Frame", {
		Name = "ColorFrame",
		Size = UDim2.new(1, 0, 1, -60),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 0, 0),
		ZIndex = 6,
		BackgroundTransparency = 0,
		Parent = Items["ColorPicker"].Instance,
	})
	
	Instances:Create("UICorner", {
		Name = "corner",
		CornerRadius = UDim.new(0, 10),
		Parent = Items["ColorFrame"].Instance,
	})
	
	Items["Saturation"] = Instances:Create("Frame", {
		Name = "Saturation",
		BorderSizePixel = 0,
		ZIndex = 6,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		Parent = Items["ColorFrame"].Instance,
	})
	
	Instances:Create("UIGradient", {
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(1,0)
		},
		Parent = Items["Saturation"].Instance,
	})
	
	Items["Value"] = Instances:Create("Frame", {
		Name = "Value",
		BorderSizePixel = 0,
		ZIndex = 6,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		Parent = Items["ColorFrame"].Instance,
	})
	
	Instances:Create("UIGradient", {
		Rotation = 90,
		Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0,1),
			NumberSequenceKeypoint.new(1,0)
		},
		Parent = Items["Value"].Instance,
	})
	
	Items["ColorPointer"] = Instances:Create("Frame", {
		Name = "ColorPointer",
		Size = UDim2.new(0, 12, 0, 12),
		Position = UDim2.new(0, 5, 0, 5),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		ZIndex = 7,
		Parent = Items["ColorFrame"].Instance,
	})
	
	Instances:Create("UICorner", {
		Name = "\0",
		CornerRadius = UDim.new(1, 0),
		Parent = Items["ColorPointer"].Instance,
	})
	
	Items["HueFrame"] = Instances:Create("Frame", {
		Name = "HueFrame",
		Size = UDim2.new(1, -6, 0, 10),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		BorderSizePixel = 0,
		ZIndex = 6,
		Parent = Items["ColorPicker"].Instance,
	})
	
	Instances:Create("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = Items["HueFrame"].Instance,
	})
	
	Instances:Create("UIGradient", {
		Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255,0,0)),
		},
		Parent = Items["HueFrame"].Instance,
	})
	
	Items["HuePointer"] = Instances:Create("Frame", {
		Size = UDim2.new(0, 16, 0, 16),
		Position = UDim2.new(0, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0,0.5),
		BackgroundColor3 = Color3.fromRGB(50,50,50),
		ZIndex = 7,
		Parent = Items["HueFrame"].Instance,
	})
	
	Instances:Create("UICorner", {
		Name = "\0",
		CornerRadius = UDim.new(0, 999),
		Parent = Items["HuePointer"].Instance,
	})
	
	Items["Row"] = Instances:Create("Frame", {
		Name = "Row",
		Size = UDim2.new(1, 0, 0, 30),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 6,
		BackgroundTransparency = 1,
		Parent = Items["ColorPicker"].Instance,
	})
	
	Instances:Create("UIListLayout", {
		FillDirection= "Horizontal",
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Parent = Items["Row"].Instance,
	})
	
	local function AddDisplay(text, value, size)
	    
		Items["HexDisplay"] = Instances:Create("TextBox", {
			Size = size or UDim2.new(1, -150, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(55,55,55),
			BorderSizePixel = 0,
			Text = value or "#69699",
			TextColor3 = Color3.fromRGB(240, 245, 240),
			BackgroundTransparency = 1,
			Font = Enum.Font.Gotham,
			TextSize = 15,
			ZIndex = 6,
			ClearTextOnFocus = false,
			MultiLine = true,
			Parent = Items["Row"].Instance,
		})
		
		Items["corner"] = Instances:Create("UICorner", {
			CornerRadius = UDim.new(0, 5),
			Parent = Items["HexDisplay"].Instance,
		})
		
		Instances:Create("UIStroke", {
			Name = "rr",
			Thickness = 0.6,
			Color = Color3.fromRGB(255, 255, 255),
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = Items["HexDisplay"].Instance,
		})
		
		Items["HexTitle"] = Instances:Create("TextLabel", {
			Size = UDim2.new(0, 0, 0, 2),
			Position = UDim2.new(0, 5, 0, 0),
		   AnchorPoint= Vector2.new(0,0.5),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
		   AutomaticSize = "X",
			ZIndex = 6,
			Text = text or "RGB",
			BackgroundTransparency = 0,
			TextColor3 = Color3.fromRGB(240, 245, 240),
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			Parent = Items["HexDisplay"].Instance,
		})
		
		Instances:Create("UIPadding", {
			PaddingLeft   = UDim.new(0, 5),
			PaddingRight  = UDim.new(0, 5),
			Parent = Items["HexTitle"].Instance,
		})
		return Items["HexDisplay"].Instance
	end
	
	local RGB= AddDisplay("RGB", "255,255,255", UDim2.new(1, -120, 1, 0))
	local HEX =AddDisplay("HEX", "#7CA3FF", UDim2.new(1, -150, 1, 0))
	

    function Colorpicker:Get()
        return Colorpicker.Color, Colorpicker.Alpha
    end

	function Colorpicker:Update()
	    local Hue, Saturation, Value = Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value
	    Colorpicker.Color = Color3.fromHSV(Hue, Saturation, Value)
	    Colorpicker.HexValue = Colorpicker.Color:ToHex()
	
	    Library.Flags[Colorpicker.Flag] = {
	        Color = Colorpicker.Color,
	        HexValue = Colorpicker.HexValue
	    }
	
	    Items["Color"]:Tween(nil, {BackgroundColor3 = Colorpicker.Color})
	    Items["ColorFrame"]:Tween(nil, {BackgroundColor3 = Color3.fromHSV(Hue, 1, 1)})
	
	    Items["Text"].Instance.Text = ("#" .. Colorpicker.HexValue):upper()
	    HEX.Text = "#" .. Colorpicker.HexValue
	
	    if Data.Callback then
	        Library:SafeCall(Data.Callback, Colorpicker.Color)
	    end
	end
	
    local SlidingPalette = false
    local PaletteChanged
    
	function Colorpicker:SlidePalette(Input)
	    if not Input or not SlidingPalette then
	        return
	    end
	
	    local ValueX = math.clamp(
	        1 - (Input.Position.X - Items["ColorFrame"].Instance.AbsolutePosition.X) / Items["ColorFrame"].Instance.AbsoluteSize.X,
	        0, 1
	    )
	
	    local ValueY = math.clamp(
	        1 - (Input.Position.Y - Items["ColorFrame"].Instance.AbsolutePosition.Y) / Items["ColorFrame"].Instance.AbsoluteSize.Y,
	        0, 1
	    )
	
	    Colorpicker.Saturation = ValueX
	    Colorpicker.Value = ValueY
	
	    local SlideX = math.clamp(
	        (Input.Position.X - Items["ColorFrame"].Instance.AbsolutePosition.X) / Items["ColorFrame"].Instance.AbsoluteSize.X,
	        0, 0.955
	    )
	
	    local SlideY = math.clamp(
	        (Input.Position.Y - Items["ColorFrame"].Instance.AbsolutePosition.Y) / Items["ColorFrame"].Instance.AbsoluteSize.Y,
	        0, 0.955
	    )
	
	    Items["ColorPointer"]:Tween(
	        TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	        {Position = UDim2.new(SlideX, 0, SlideY, 0)}
	    )
	
	    Colorpicker:Update()
	end
    
    local SlidingHue = false
    local HueChanged

	function Colorpicker:SlideHue(Input)
	    if not Input or not SlidingHue then
	        return
	    end
	
	    local ValueX = math.clamp(
	        (Input.Position.X - Items["HueFrame"].Instance.AbsolutePosition.X) / Items["HueFrame"].Instance.AbsoluteSize.X,
	        0, 1
	    )
	
	    Colorpicker.Hue = ValueX
	
	    local SlideX = math.clamp(
	        (Input.Position.X - Items["HueFrame"].Instance.AbsolutePosition.X) / Items["HueFrame"].Instance.AbsoluteSize.X,
	        0, 0.955
	    )
	
	    Items["HuePointer"]:Tween(
	        TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	        {Position = UDim2.new(SlideX, 0, 0.5, 0)}
	    )
	
	    Colorpicker:Update()
	end
	
    local Debounce = false
    local RenderStepped  

    function Colorpicker:SetOpen(Bool)
        if Debounce then 
            return
        end

        Colorpicker.IsOpen = Bool

        Debounce = true 

        if Colorpicker.IsOpen then 
            Items["ColorPicker"].Instance.Visible = true
            Items["ColorPicker"].Instance.Parent = Library.Holder.Instance
            
            RenderStepped = RunService.RenderStepped:Connect(function()
                Items["ColorPicker"].Instance.Position = UDim2.new(
                    0, 
                    Items["ColorpickerButton"].Instance.AbsolutePosition.X, 
                    0, 
                    Items["ColorpickerButton"].Instance.AbsolutePosition.Y + Items["ColorpickerButton"].Instance.AbsoluteSize.Y + 5
                )
            end)

            if Data.Section.IsSettings ~= true then
                for Index, Value in Library.OpenFrames do 
                    if Value ~= Colorpicker then
                        Value:SetOpen(false)
                    end
                end
            end

            Library.OpenFrames[Colorpicker] = Colorpicker 
        else
            if not Data.Section.IsSettings then
                if Library.OpenFrames[Colorpicker] then 
                    Library.OpenFrames[Colorpicker] = nil
                end
            end

            if RenderStepped then 
                RenderStepped:Disconnect()
                RenderStepped = nil
            end
        end

        local Descendants = Items["ColorPicker"].Instance:GetDescendants()
        TableInsert(Descendants, Items["ColorPicker"].Instance)

        local NewTween

        for Index, Value in Descendants do 
            local TransparencyProperty = Tween:GetProperty(Value)

            if not TransparencyProperty then
                continue 
            end

            if not Value.ClassName:find("UI") then 
                Value.ZIndex = (Colorpicker.IsOpen and Data.Section.IsSettings and 9) or (Colorpicker.IsOpen and not Data.Section.IsSettings and 9) or 1
            end

            if type(TransparencyProperty) == "table" then 
                for _, Property in TransparencyProperty do 
                    NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                end
            else
                NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
            end
        end
        
        NewTween.Tween.Completed:Connect(function()
            Debounce = false 
            Items["ColorPicker"].Instance.Visible = Colorpicker.IsOpen
            task.wait(0.2)
            Items["ColorPicker"].Instance.Parent = not Colorpicker.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
        end)
    end

	function Colorpicker:Set(Color)
	    if type(Color) == "table" then
	        Color = Color3.fromRGB(Color[1], Color[2], Color[3])
	    elseif type(Color) == "string" then
	        Color = FromHex(Color)
	    end 
	
	    Colorpicker.Hue, Colorpicker.Saturation, Colorpicker.Value = Color:ToHSV()
	
	    local PaletteValueX = math.clamp(1 - Colorpicker.Saturation, 0, 0.955)
	    local PaletteValueY = math.clamp(1 - Colorpicker.Value, 0, 0.955)
	
	    local HuePositionX = math.clamp(Colorpicker.Hue, 0, 0.955)
	
	    Items["ColorPointer"]:Tween(
	        TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	        {Position = UDim2.new(PaletteValueX, 0, PaletteValueY, 0)}
	    )
	
	    Items["HuePointer"]:Tween(
	        TweenInfo.new(Library.Tween.Time, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
	        {Position = UDim2.new(HuePositionX, 0, 0.5, 0)}
	    )
	
	    Colorpicker:Update()
	end

    Items["ColorpickerButton"]:Connect("MouseButton1Down", function()
        Colorpicker:SetOpen(not Colorpicker.IsOpen)
    end)

    Items["ColorFrame"]:Connect("InputBegan", function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            SlidingPalette = true 

            Colorpicker:SlidePalette(Input)

            if PaletteChanged then
                return
            end

            PaletteChanged = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    SlidingPalette = false

                    PaletteChanged:Disconnect()
                    PaletteChanged = nil
                end
            end)
        end
    end)

    Items["HueFrame"]:Connect("InputBegan", function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            SlidingHue = true 

            Colorpicker:SlideHue(Input)

            if HueChanged then
                return
            end

            HueChanged = Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    SlidingHue = false

                    HueChanged:Disconnect()
                    HueChanged = nil
                end
            end)
        end
    end)
--[[
    hex:Connect("FocusLost", function()
        Colorpicker:Set(tostring(Items["HEXInput"].Instance.Text), Colorpicker.Alpha)
    end)
]]
    Library:Connect(UserInputService.InputChanged, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            if SlidingPalette then 
                Colorpicker:SlidePalette(Input)
            end

            if SlidingHue then
                Colorpicker:SlideHue(Input)
            end

            if SlidingAlpha then
                Colorpicker:SlideAlpha(Input)
            end
        end
    end)

    Library:Connect(UserInputService.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if not Colorpicker.IsOpen then
                return
            end

            if Library:IsMouseOverFrame(Items["ColorpickerWindow"]) or Library:IsMouseOverFrame(Items["PaletteIcon"]) and not Data.Section.IsSettings then
                return
            end

            Colorpicker:SetOpen(false)
        end
    end)

    if Data.Default then
        Colorpicker:Set(Data.Default, Data.Alpha)
    end

    Library.SetFlags[Colorpicker.Flag] = function(Value, Alpha)
        Colorpicker:Set(Value, Alpha)
    end

    return Colorpicker, Items 
end

Library.Window = function(self, Data)
    Data = Library.Sanitize(Data or {})

    local Window = {
        Name = Data.Name or "Window",
        SubName = Data.SubName or "Fine-tuning for sure wins",
        Icon = Data.Icon or "house",
        
        Pages = { },
        Items = { },
        IsOpen = false,
        IsTabOpen = false,
        CurrentAlignment = "LeftTabs"
    }

    local Items = { }

    Items["MainFrame"] = Instances:Create("Frame", {
        Size = UDim2.new(0, 530, 0, 370),
        Position = UDim2.new(0.5, -270, 0.5, -200),
        BackgroundColor3 = Library.Theme.Background,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        ZIndex = 2,
        Parent = Library.Holder.Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["MainFrame"].Instance, CornerRadius = UDim.new(0, 14)})
    Instances:Create("UIScale", { Parent = Library.Holder.Instance, Scale = 0.82})

    if IsMobile then
        Items["FloatingButton"] = Instances:Create("ImageButton", {
            Parent = Library.Holder.Instance,
            Position = UDim2.new(0.5, 0, 0, 20),
            AnchorPoint = Vector2.new(0.5, 0),
            Visible = false,
            Size = UDim2.new(0, 100, 0, 45),
            AutomaticSize = "X",
            BackgroundTransparency = 0,
            ZIndex = 100,
            BackgroundColor3 = Library.Theme.Background
        })

        Items["FloatingLogo"] = Instances:Create("ImageLabel", {
            Parent = Items["FloatingButton"].Instance,
            Image = LucideIcon["sparkle"],
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 5, 0.5, 0),
            ZIndex = 100,
            Size = UDim2.new(0,20,0,20),
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        })
        
        Items["FloatingTitle"] = Instances:Create("TextLabel", {
	        BackgroundTransparency = 1,
	        Text = Window.Name,
	        TextColor3 = Library.Theme.PrimaryText,
	        Font = Enum.Font.GothamBold,
	        TextSize = 17,
	        Size = UDim2.new(1,-30,1,0),
			Position = UDim2.new(0,30,0,0),
	        TextXAlignment = Enum.TextXAlignment.Left,
	        ZIndex = 100,
	        Parent = Items["FloatingButton"].Instance,
	    })

        Instances:Create("UICorner", {
            Parent = Items["FloatingButton"].Instance,
            CornerRadius = UDim.new(0, 14)
        }) 
        
        Instances:Create("UIPadding", { 
	        Parent = Items["FloatingButton"].Instance, 
	        PaddingLeft = UDim.new(0,10), 
	        PaddingRight = UDim.new(0,10)
	    })
        
        HoverTween(Items["FloatingButton"].Instance, {
		    {Items["FloatingTitle"], {TextColor3 = Library.Theme.Background}, {TextColor3 = Library.Theme.PrimaryText}},
		    {Items["FloatingButton"],  {BackgroundColor3 = Library.Theme.Primary}, {BackgroundColor3 = Library.Theme.Background}},
		})

    end
    
    Items["TopBar"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Library.Theme.Surface,
        ZIndex = 3,
        BackgroundTransparency = 1,
        Parent = Items["MainFrame"].Instance,
    }) 
    
    Instances:Create("UIPadding", { 
        Parent = Items["TopBar"].Instance, 
        PaddingLeft = UDim.new(0,8), 
        PaddingRight = UDim.new(0,8)
    })
    
    Items["Logo"] = Instances:Create("ImageLabel", {
		Size = UDim2.new(0, 30, 1, -20),
		Position = UDim2.new(0, 5, 0.5, 0),
	    AnchorPoint= Vector2.new(0,0.5),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Image = Library:ResolveImage(Window.Icon),
		ImageTransparency = 0,
		ScaleType = Enum.ScaleType.Fit,
		BackgroundTransparency = 1,
		ZIndex = 4,
		Parent = Items["TopBar"].Instance,
	})
    
    Items["Brand"] = Instances:Create("Frame", {
        Size = UDim2.new(0, 200, 1, -20),
        Position = UDim2.new(0, 45, 0.5, 0),
        AnchorPoint= Vector2.new(0,0.5),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Items["TopBar"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Brand"].Instance, 
        FillDirection = "Vertical",
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,1),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    
    Items["BrandName"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Window.Name,
        TextColor3 = Library.Theme.PrimaryText,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        Size = UDim2.new(1,0,0.5,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["Brand"].Instance,
    })
    
    Items["BrandSub"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Window.SubName,
        TextColor3 = Library.Theme.MutedText,
        Font = Enum.Font.Gotham,
        TextSize = 13,
        Size = UDim2.new(1,0,0.5,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["Brand"].Instance,
    })
    
    Items["WindowControls"] = Instances:Create("Frame", {
        Size = UDim2.new(0, 0, 1, -25),
        Position = UDim2.new(1, -5, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        ZIndex = 4,
        AutomaticSize = "X",
        Parent = Items["TopBar"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["WindowControls"].Instance, 
        FillDirection = "Horizontal",
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,3),
        HorizontalAlignment = "Right",
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    
    local function AddControls(key, logo)
	    local control = Instances:Create("ImageButton", {
	        Size = UDim2.new(0, 25, 1, 0),
	        ImageColor3 = Library.Theme.SecondaryText,
	        Image = logo,
	        ImageTransparency = 0,
	        ZIndex = 4,
	        ScaleType = Enum.ScaleType.Fit,
	        BackgroundTransparency = 1,
	        Parent = Items["WindowControls"].Instance,
	    })
	
	    Items[key] = control
	    return control
	end
	
	Items["Minimize"] = AddControls("Minimize", LucideIcon["minus"])
	Items["Close"] = AddControls("Close", LucideIcon["x"])
	
	HoverTween(Items["Minimize"].Instance, {
	    {Items["Minimize"], {ImageColor3 = Library.Theme.Primary}, {ImageColor3 = Library.Theme.MutedText}},
	})
	
	HoverTween(Items["Close"].Instance, {
	    {Items["Close"], {ImageColor3 = Library.Theme.Danger}, {ImageColor3 = Library.Theme.MutedText}},
	})
    
    Items["Divider"] = Instances:Create("Frame", {
        Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.new(0, 12, 0, 64),
        BackgroundColor3 = Library.Theme.Border,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = Items["TopBar"].Instance,
    })
    
    Items["Nav"] = Instances:Create("Frame", {
        Size = UDim2.new(0, 150, 1, -50),
        Position = UDim2.new(0, 0, 0, 50),
        BackgroundColor3 = Library.Theme.Surface,
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = Items["MainFrame"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["Nav"].Instance, CornerRadius = UDim.new(0, 14)})
    
    
    Items["Scroll"] = Instances:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 4,
        Parent = Items["Nav"].Instance,
    })
    
    Instances:Create("UIPadding", { 
        Parent = Items["Scroll"].Instance, 
        PaddingTop = UDim.new(0, 5), 
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0,5), 
        PaddingRight = UDim.new(0,5)
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Scroll"].Instance, 
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })
    
    Items["Body"] = Instances:Create("Frame", {
        Size = UDim2.new(1, -160, 1, -50),
        Position = UDim2.new(0, 160, 0, 50),
        BackgroundTransparency = 1,
        ZIndex = 3,
        Parent = Items["MainFrame"].Instance,
    })
    
    Items["DragHandle"] = Instances:Create("ImageButton", {
		Size = UDim2.new(0, 90, 0, 10),
		Position = UDim2.new(0.5, 0, 1, -5),
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundColor3 = Color3.fromRGB(35, 35, 35),
		ZIndex = 5,
		Active = true,
		BackgroundTransparency = 1,
		Parent = Items["Body"].Instance,
	})

	Items["Pill"] = Instances:Create("ImageLabel", {
		Name = "Pill",
		Size = UDim2.new(1, 0, 0, 5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(90, 90, 90),
		BorderSizePixel = 0,
		ZIndex = 6,
		BackgroundTransparency = 0,
		Parent = Items["DragHandle"].Instance,
	})
		Instances:Create("UICorner", {
			CornerRadius = UDim.new(1, 0),
			Parent = Items["Pill"].Instance,
	})
	
	Items["ListControls"] = Instances:Create("Frame", {
		Size = UDim2.new(1, -20, 0, 30),
		Position = UDim2.new(0, 10, 1, -30),
		BackgroundColor3 = Library.Theme.Surface,
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = 5,
		Visible = true,
		Parent = Items["Body"].Instance,
	})
	
	Instances:Create("UIListLayout", { 
		Parent = Items["ListControls"].Instance, 
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0,6),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center
	})
		
    
    -- _Content
    Items["_Content"] = Instances:Create("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Library.Theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
        Parent = Items["Body"].Instance,
    })
    
    Instances:Create("UIPadding", { 
        Parent = Items["_Content"].Instance, 
        PaddingTop = UDim.new(0, 10), 
        PaddingBottom = UDim.new(0, 14),
        PaddingLeft = UDim.new(0,16), 
        PaddingRight = UDim.new(0,16)
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["_Content"].Instance, 
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,6),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })
    
    
    Items["SearchFrame"] = Instances:Create("Frame", {
		Size = UDim2.new(0, 215, 1, -5),
		BackgroundColor3 = Library.Theme.SurfaceAlt,
		BackgroundTransparency = 0,
		ZIndex = 4,
		Parent = Items["ListControls"].Instance,
	})
    Instances:Create("UICorner", { Parent = Items["SearchFrame"].Instance, CornerRadius = UDim.new(0, 14)})
    
    Instances:Create("UIPadding", { 
        Parent = Items["SearchFrame"].Instance, 
        PaddingTop = UDim.new(0, 3), 
        PaddingBottom = UDim.new(0, 3),
        PaddingLeft = UDim.new(0,3), 
        PaddingRight = UDim.new(0,3)
    })
    
    Items["SearchInput"] = Instances:Create("TextBox", {
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "Search here...",
        TextColor3 = Library.Theme.MutedText,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Size = UDim2.new(1,-35,1,0),
        Position = UDim2.new(0,35,0,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
        Parent = Items["SearchFrame"].Instance,
    })
    
    Items["SearchFrameIcon"] = Instances:Create("ImageLabel", {
		Size = UDim2.new(0, 30, 1, 0),
		Position = UDim2.new(0, 0, 0.5, 0),
	    AnchorPoint= Vector2.new(0,0.5),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		ImageColor3 = Color3.fromRGB(255, 255, 255),
		Image = LucideIcon["search"],
		ImageTransparency = 0,
		ScaleType = Enum.ScaleType.Fit,
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = Items["SearchFrame"].Instance,
	})
	
	Items["PaginationFrame"] = Instances:Create("Frame", {
		Size = UDim2.new(1, -225, 1, 0),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = Items["ListControls"].Instance,
	})
    
    Instances:Create("UIListLayout", { 
		Parent = Items["PaginationFrame"].Instance,
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0,1),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center
	})
	
	Items["LeftPage"] = Instances:Create("ImageButton", {
		Size = UDim2.new(0,25,1,-6),
		Image = LucideIcon["chevron-left"],
		ImageColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = Items["PaginationFrame"].Instance,
	})
	
	Items["PageInput"] = Instances:Create("TextBox", {
		BackgroundTransparency = 1,
		Text = "?",
		TextColor3 = Library.Theme.PrimaryText,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		Size = UDim2.new(0,35,1,0),
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = 5,
		Parent = Items["PaginationFrame"].Instance,
	})
	
	Items["LastPage"] = Instances:Create("TextLabel", {
		BackgroundTransparency = 1,
		Text = "/?",
		TextColor3 = Library.Theme.PrimaryText,
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		Size = UDim2.new(0,35,1,0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 5,
		Parent = Items["PaginationFrame"].Instance,
	})
    
	Items["RightPage"] = Instances:Create("ImageButton", {
		Size = UDim2.new(0,25,1,-6),
		Image = LucideIcon["chevron-right"],
		ImageColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 1,
		ZIndex = 5,
		Parent = Items["PaginationFrame"].Instance,
	})
    
    Window.Items = Items
    
    Items["RightPage"].Instance.MouseButton1Click:Connect(function()
		for _, page in ipairs(Window.Pages) do
			if page.Active then
	
				local totalPages = math.max(1, math.ceil(page.TotalItems / page.ItemsPerPage))
	
				if page.PageIndex < totalPages then
					page.PageIndex += 1
					page:UpdatePagination()
				end
	
			end
		end
	end)
	
	Items["LeftPage"].Instance.MouseButton1Click:Connect(function()
	    for _, page in ipairs(Window.Pages) do
	        if page.Active then
	            page.PageIndex = math.max(1, page.PageIndex - 1)
	            page:UpdatePagination()
	        end
	    end
	end)
	
	
	function Search(str)
		str = string.lower(str)
	
		for _, page in pairs(Window.Pages) do
			if not page.Active then continue end
	
			for _, section in pairs(page.Sections) do
				local container = section.Items["Content"].Instance
	
				for _, obj in ipairs(container:GetChildren()) do
					if obj:IsA("GuiObject") then
	
						local label
	
						for _, child in ipairs(obj:GetDescendants()) do
							if child:IsA("TextLabel") then
								label = child
								break
							end
						end
	
						if label then
							local name = string.lower(label.Text or "")
	
							if str == "" or string.find(name, str, 1, true) then
								obj.Visible = true
							else
								obj.Visible = false
							end
						end
	
					end
				end
			end
		end
	end

	Items["SearchInput"].Instance:GetPropertyChangedSignal("Text"):Connect(function()
		Search(Items["SearchInput"].Instance.Text)
	end)
	
    function Window:SetOpen(Bool)
        if Debounce then 
            return
        end

        Window.IsOpen = Bool

        Debounce = true 

        if Window.IsOpen then 
            Items["MainFrame"].Instance.Visible = true 
        end
        
        --if IsMobile then 
	        Items["FloatingButton"].Instance.Visible = not Bool
	    --end

        local Descendants = Items["MainFrame"].Instance:GetDescendants()
        table.insert(Descendants, Items["MainFrame"].Instance)

        local NewTween

        for Index, Value in Descendants do 
            local TransparencyProperty = Tween:GetProperty(Value)

            if not TransparencyProperty then
                continue 
            end

            if type(TransparencyProperty) == "table" then 
                for _, Property in TransparencyProperty do 
                    NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                end
            else
                NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
            end
        end
        
        NewTween.Tween.Completed:Connect(function()
            Debounce = false 
            Items["MainFrame"].Instance.Visible = Window.IsOpen
        end)
    end
    
    Items["Minimize"].Instance.MouseButton1Click:Connect(function()
		Window:SetOpen(false)
	end)
    
    --if IsMobile then 
        Items["FloatingButton"].Instance.MouseButton1Click:Connect(function()   
            Window:SetOpen(not Window.IsOpen)
        end)
    --end
    --[[
    Library:Connect(UserInputService.InputBegan, function(Input)
        if tostring(Input.KeyCode) == Library.MenuKeybind or tostring(Input.UserInputType) == Library.MenuKeybind then
            Window:SetOpen(not Window.IsOpen)
        end
    end)
]]
    function Window:SetCenter()
        local CenterPosition = Items["MainFrame"].Instance.AbsolutePosition
        task.wait()
        Items["MainFrame"].Instance.AnchorPoint = Vector2.new(0, 0)
        Items["MainFrame"].Instance.Position = UDim2.new(0, CenterPosition.X, 0, CenterPosition.Y)
    end
    
    Window:SetCenter()
    Window:SetOpen(true)
    return setmetatable(Window, Library)
end

Library.Page = function(self, Data)
    Data = Library.Sanitize(Data or {})
    
	local Page = {
	    Window = self,
	    Name = Data.Name or "Main",
	    Desc = Data.Description or "Main is shit",
	    Icon = Data.Icon or "100050851789190",
	
	    Items = { },
	    Sections = { },
	
	    Active = false,
	
	    PageIndex = 1,
	    ItemsPerPage = Data.ItemsPerPage or 50,
	    TotalItems = 0,
	}
	    
    local Items = {}
    
    Items["Inactive"] = Instances:Create("ImageButton", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundColor3 = Library.Theme.SurfaceAlt,
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        ZIndex = 5,
        Parent = Page.Window.Items["Scroll"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["Inactive"].Instance, CornerRadius = UDim.new(0, 9)})
    
    Instances:Create("UIPadding", { 
        Parent = Items["Inactive"].Instance, 
        PaddingTop = UDim.new(0, 0), 
        PaddingBottom = UDim.new(0,0),
        PaddingLeft = UDim.new(0,10), 
        PaddingRight = UDim.new(0,8)
    })

    Items["Pill"] = Instances:Create("Frame", {
        Size = UDim2.new(0, 3, 0.55, 0),
        Position = UDim2.new(0, -10, 0.225, 0),
        BackgroundColor3 = Library.Theme.Accent,
        BackgroundTransparency = 1,
        ZIndex = 6,
        Parent = Items["Inactive"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["Pill"].Instance, CornerRadius = UDim.new(0, 4)})
    
    Items["Row"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 5,
        Parent = Items["Inactive"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Row"].Instance, 
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0,9),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    
    Items["Icon"] = Instances:Create("ImageLabel", {
        Size = UDim2.new(0, 16, 0, 16),
        BackgroundTransparency = 1,
        Image = Library:ResolveImage(Page.Icon),
        ImageColor3 = Library.Theme.MutedText,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
        Parent = Items["Row"].Instance,
    })
    
    Items["Title"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Page.Name,
        TextColor3 = Library.Theme.SecondaryText,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
        Size = UDim2.new(1,-25,1,0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 5,
        Parent = Items["Row"].Instance,
    })
    
    Items["Page"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 3,
        Parent = Library.UnusedHolder.Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Page"].Instance, 
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,5),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })
    
    Page.Items = Items
    
    function Page:UpdatePagination()
	    local itemsPerPage = Page.ItemsPerPage
	    local pageIndex = Page.PageIndex
	
	    local startIndex = (pageIndex - 1) * itemsPerPage + 1
	    local endIndex = startIndex + itemsPerPage - 1
	
	    local count = 0
	
	    for _, section in pairs(Page.Sections) do
	        local container = section.Items["Content"].Instance
	
	        for _, obj in ipairs(container:GetChildren()) do
	            if obj:IsA("GuiObject") then
	                count += 1
	
	                if count >= startIndex and count <= endIndex then
	                    obj.Visible = true
	                else
	                    obj.Visible = false
	                end
	            end
	        end
	    end
	
	    Page.TotalItems = count
	    local totalPages = math.max(1, math.ceil(count / itemsPerPage))
	
	    if Page.PageIndex > totalPages then
	        Page.PageIndex = totalPages
	    end
	
	    Page.Window.Items["PageInput"].Instance.Text = tostring(Page.PageIndex)
	    Page.Window.Items["LastPage"].Instance.Text = "/" .. totalPages
	
		local left = Page.Window.Items["LeftPage"].Instance
		local right = Page.Window.Items["RightPage"].Instance
		
		if Page.PageIndex <= 1 then
			left.ImageTransparency = 0.6
			left.Active = false
		else
			left.ImageTransparency = 0
			left.Active = true
		end
		
		if Page.PageIndex >= totalPages then
			right.ImageTransparency = 0.6
			right.Active = false
		else
			right.ImageTransparency = 0
			right.Active = true
		end
	end

    local Debounce = false

    function Page:Turn(Bool)
        if Debounce then 
            return 
        end

        Page.Active = Bool  

		if Bool then
		    Page.PageIndex = 1
		    Page:UpdatePagination()
		end

        Debounce = true
        
        Page.Items["Page"].Instance.Visible = Bool 
        Page.Items["Page"].Instance.Parent = Bool and Page.Window.Items["_Content"].Instance or Library.UnusedHolder.Instance

        if Page.Active then
            Items["Inactive"]:Tween(nil, {BackgroundTransparency = 0.25})
            Items["Page"]:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})

            for Index, Value in pairs(Page.Sections) do 
                task.spawn(function()
                    if Value.TweenElements then
                        Value:TweenElements(true)
                    end
                end)
            end
        else
            Items["Inactive"]:Tween(nil, {BackgroundTransparency = 1})
            Items["Page"]:Tween(TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 60)})
        end

        local AllInstances = Page.Items["Page"].Instance:GetDescendants()
        table.insert(AllInstances, Page.Items["Page"].Instance)
        
        local NewTween 

        for Index, Value in ipairs(AllInstances) do 
            local TransparencyProperty = Tween:GetProperty(Value)

            if not TransparencyProperty then 
                continue
            end

            if type(TransparencyProperty) == "table" then 
                for _, Property in ipairs(TransparencyProperty) do 
                    NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                end
            else
                NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
            end
        end

        if NewTween and NewTween.Tween then
            Library:Connect(NewTween.Tween.Completed, function()
                Debounce = false

                if not Page.Active then 
                    for Index, Value in pairs(Page.Sections) do 
                        task.spawn(function()
                            if Value.TweenElements then
                                Value:TweenElements(false, true)
                            end
                        end)   
                    end
                end
            end)
        else
            Debounce = false
        end
    end

    Items["Inactive"]:Connect("MouseButton1Down", function()
	    
        for Index, Value in ipairs(Page.Window.Pages) do 
            if Value == Page and Page.Active then
                return
            end

            Value:Turn(Value == Page)
        end
    end)
    
	HoverTween(Items["Inactive"].Instance, {
	    {Items["Title"], {TextColor3 = Library.Theme.Primary}, {TextColor3 = Library.Theme.SecondaryText}},
	    {Items["Icon"],  {ImageColor3 = Library.Theme.Primary}, {ImageColor3 = Library.Theme.MutedText}},
	})

    if #Page.Window.Pages == 0 then 
        Page:Turn(true)
    end
    
    table.insert(Page.Window.Pages, Page)
    return setmetatable(Page, Library.Pages)
end

Library.Pages.Section = function(self, Data)
    Data = Library.Sanitize(Data or {})

    local Section = {
        Window = self.Window,
        Page = self,

        Name = Data.Name or "Section",
        Icon = Data.Icon or "123944728972740",
        EnableToggle = Data.EnableToggle or false,

        Items = { },
        IsActive = true,
        Elements = { }
    }
    
    local Items = {}
    
    Items["Wrapper"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
        Parent = Section.Page.Items["Page"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Wrapper"].Instance, 
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,5),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })
    
    Items["Title"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Section.Name,
        TextColor3 = Library.Theme.MutedText,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        LayoutOrder = 0,
        Size = UDim2.new(1,0,0,14),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = Items["Wrapper"].Instance,
    })

    Items["Content"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        ZIndex = 3,
        Parent = Items["Wrapper"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Content"].Instance,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,4),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })
    
    Section.Items = Items
    
    Section.Page.Sections[Section.Name] = Section
    return setmetatable(Section, Library.Sections)
end

Library.Pages.GridSection = function(self, Data)
    Data = Library.Sanitize(Data or {})

    local Section = {
        Window = self.Window,
        Page = self,

        Name = Data.Name or "GridSection",
        Icon = Data.Icon or "123944728972740",
        EnableToggle = Data.EnableToggle or false,

        Cell = Data.Cell or {},
        CellHeight = Data.Cell.Height or 120,
        CellWidth = Data.Cell.Width or 50,
        Padding = Data.Cell.Padding or 12,
        

        Items = { },
        IsActive = true,
        Elements = { }
    }

    local Items = {}

    Items["Wrapper"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 3,
        Parent = Section.Page.Items["Page"].Instance,
    })

    Instances:Create("UIListLayout", {
        Parent = Items["Wrapper"].Instance,
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0,5),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top
    })

    Items["Title"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Section.Name,
        TextColor3 = Library.Theme.MutedText,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        LayoutOrder = 0,
        Size = UDim2.new(1,0,0,14),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 3,
        Parent = Items["Wrapper"].Instance,
    })

    Items["Content"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 1,
        ZIndex = 3,
        Parent = Items["Wrapper"].Instance,
    })

    local Grid = Instances:Create("UIGridLayout", {
	    Parent = Items["Content"].Instance,
	    CellSize = UDim2.fromOffset(Section.CellWidth, Section.CellHeight),
	    CellPadding = UDim2.new(0, Section.Padding, 0, Section.Padding),
	    FillDirection = Enum.FillDirection.Horizontal,
	    SortOrder = Enum.SortOrder.LayoutOrder,
	    HorizontalAlignment = Enum.HorizontalAlignment.Left,
	    VerticalAlignment = Enum.VerticalAlignment.Top
	})

    Section.Items = Items

    Section.Page.Sections[Section.Name] = Section
    return setmetatable(Section, Library.Sections)
end

Library.Sections.CreateElements = function(self, ClassName, Data)
    Data = Data or {}

    if Data.Parent == self then
        Data.Parent = self.Items["Content"].Instance
    end

    return Instances:Create(ClassName, Data)
end


Library.Sections.Button = function(self, Data)         
    Data = Library.Sanitize(Data or {})

    local Button = {
        Window = self.Window,
        Page = self.Page,
        Section = self,

        Name = Data.Name or "Button",
        Desc = Data.Description or nil,
        Callback = Data.Callback or function() end
    }
    
    local Items = {}
    
    Items["Button"] = Instances:Create("ImageButton", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Library.Theme.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 4,
        AutomaticSize = "Y",
        Parent = Button.Section.Items["Content"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["Button"].Instance, CornerRadius = UDim.new(0, 9)})
    
    Instances:Create("UIPadding", { 
        Parent = Items["Button"].Instance, 
        PaddingTop = UDim.new(0, 10), 
        PaddingBottom = UDim.new(0,10),
        PaddingLeft = UDim.new(0,14), 
        PaddingRight = UDim.new(0,14)
    })

    Items["Row"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Items["Button"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Row"].Instance, 
        FillDirection = "Horizontal",
        Padding = UDim.new(0,12),
        HorizontalAlignment = "Left",
        VerticalAlignment = "Center",
    })
    
    Items["TitleFrame"] = Instances:Create("Frame", {
        Size = UDim2.new(1, -48, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 4,
        AutomaticSize = "Y",
        Parent = Items["Row"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["TitleFrame"].Instance, 
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,3),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    
    Items["Title"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Button.Name,
        TextColor3 = Library.Theme.PrimaryText,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        AutomaticSize = "Y",
        TextWrapped = true,
        Size = UDim2.new(1,0,0,15),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["TitleFrame"].Instance,
    })
    
    Items["Description"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Button.Desc,
        TextColor3 = Library.Theme.SecondaryText,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutomaticSize = "Y",
        TextWrapped = true,
        Visible = Button.Desc ~= nil and Button.Desc ~= "",
        Size = UDim2.new(1,0,0,13),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["TitleFrame"].Instance,
    })
    
    Items["IcoWrap"] = Instances:Create("Frame", {
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = Library.Theme.SurfaceAlt,
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Items["Row"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["IcoWrap"].Instance, CornerRadius = UDim.new(0, 9)})

    Items["Ico"] = Instances:Create("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0.5, 0, 0.5, -9),
        BackgroundTransparency = 1,
        Image = LucideIcon["chevron-right"],
        ImageColor3 = Library.Theme.MutedText,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
        Parent = Items["IcoWrap"].Instance,
    })
    
    function Button:SetVisibility(Bool)
        Items["Button"].Instance.Visible = Bool
    end

    function Button:OnClick()
        local buttonTween = Tween:Create(Items["Button"].Instance, nil, {BackgroundColor3 = Library.Theme.Accent})
        
        local titleTween = Tween:Create(Items["Title"].Instance, nil, {
            TextColor3 = Color3.new(0, 0, 0),
            TextTransparency = 0
        })
        
        task.wait(0.2)

        Library:SafeCall(Button.Callback)
        
        local buttonTween2 = Tween:Create(Items["Button"].Instance, nil, {BackgroundColor3 = Library.Theme.Surface})
        local titleTween2 = Tween:Create(Items["Title"].Instance, nil, {
            TextColor3 = Library.Theme.PrimaryText,
            TextTransparency = 0.3
        })
    end

    Items["Button"]:Connect("MouseButton1Down", function()
        Button:OnClick()
    end)

    return Button
end

Library.Sections.Label = function(self, Data)         
    Data = Library.Sanitize(Data or {})

    local Label = {
        Window = self.Window,
        Page = self.Page,
        Section = self,

        Name = Data.Name or "Label",
        Desc = Data.Description or nil
    }
    
    local Items = {}
    
    Items["Label"] = Instances:Create("ImageButton", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Library.Theme.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 4,
        AutomaticSize = "Y",
        Parent = Label.Section.Items["Content"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["Label"].Instance, CornerRadius = UDim.new(0, 9)})
    
    Instances:Create("UIPadding", { 
        Parent = Items["Label"].Instance, 
        PaddingTop = UDim.new(0, 10), 
        PaddingBottom = UDim.new(0,10),
        PaddingLeft = UDim.new(0,14), 
        PaddingRight = UDim.new(0,14)
    })

    Items["Row"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Items["Label"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Row"].Instance, 
        FillDirection = "Horizontal",
        Padding = UDim.new(0,12),
        HorizontalAlignment = "Left",
        VerticalAlignment = "Center",
    })
    
    Items["TitleFrame"] = Instances:Create("Frame", {
        Size = UDim2.new(1, -48, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 4,
        AutomaticSize = "Y",
        Parent = Items["Row"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["TitleFrame"].Instance, 
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,3),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    
    Items["Title"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Label.Name,
        TextColor3 = Library.Theme.PrimaryText,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        AutomaticSize = "Y",
        TextWrapped = true,
        Size = UDim2.new(1,0,0,15),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["TitleFrame"].Instance,
    })
    
    Items["Description"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Label.Desc,
        TextColor3 = Library.Theme.SecondaryText,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        Visible = Label.Desc ~= nil and Label.Desc ~= "",
        AutomaticSize = "Y",
        TextWrapped = true,
        Size = UDim2.new(1,0,0,13),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["TitleFrame"].Instance,
    })
    
    Items["IcoWrap"] = Instances:Create("Frame", {
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = Library.Theme.SurfaceAlt,
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Items["Row"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["IcoWrap"].Instance, CornerRadius = UDim.new(0, 9)})
    
    function Label:SetText(Title, Desc)

	    if Title ~= nil then
	        Label.Name = tostring(Title)
	        Items["Title"].Instance.Text = Label.Name
	    end
	
	    if Desc ~= nil then
	        Label.Desc = tostring(Desc)
	        Items["Description"].Instance.Text = Label.Desc
	        Items["Description"].Instance.Visible = Label.Desc ~= ""
	    end
	
	end

    function Label:SetVisibility(Bool)
        Items["Label"].Instance.Visible = Bool
    end
    
	function Label:Colorpicker(Data)
        Data = Data or { }

        local Colorpicker = {
            Window = Label.Window,
            Page = Label.Page,
            Section = Label.Section,

            Flag = Data.Flag or Data.flag or Library:NextFlag(),
            Default = Data.Default or Data.default or Color3.fromRGB(255, 255, 255),
            Callback = Data.Callback or Data.callback or function() end,
            Alpha = Data.Alpha or Data.alpha or false
        }

        if not Items["IcoWrap"] then
            Items["IcoWrap"] = Instances:Create("Frame", {
                Parent = Items["Label"].Instance,
                Name = "\0",
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 30),
                BorderColor3 = FromRGB(0, 0, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                BackgroundColor3 = FromRGB(27, 26, 29)
            })  
            
            Instances:Create("UICorner", {
                Parent = Items["SubElements"].Instance,
                Name = "\0",
                CornerRadius = UDimNew(0, 5)
            })
            
            Instances:Create("UIListLayout", {
                Parent = Items["IcoWrap"].Instance,
                Name = "\0",
                VerticalAlignment = Enum.VerticalAlignment.Center,
                FillDirection = Enum.FillDirection.Horizontal,
                Padding = UDimNew(0, 5),
                SortOrder = Enum.SortOrder.LayoutOrder
            })

            Instances:Create("UIPadding", {
                Parent = Items["IcoWrap"].Instance,
                Name = "\0",
                PaddingLeft = UDimNew(0, 6)
            })                
        end

        --Label.Section.Items["Fade"].Instance.Size = UDim2.new(1, 0, 0, Label.Section.Items["Content"].Instance.AbsoluteSize.X - 180)

        local NewColorpicker, ColorpickerItems = Library:CreateColorpicker({
            Parent = Items["IcoWrap"],
            Page = Colorpicker.Page,
            Section = Colorpicker.Section,
            Flag = Colorpicker.Flag,
            Default = Colorpicker.Default,
            Callback = Colorpicker.Callback,
            Parent2 = Items["Label"],
        })

        return NewColorpicker
    end

    Label.Section.Elements[#Label.Section.Elements+1] = Label
    return Label
end

Library.Sections.Toggle = function(self, Data)
    Data = Library.Sanitize(Data or {})
    
    local Toggle = {
        Window = self.Window,
        Page = self.Page,
        Section = self,

        Name = Data.Name or "Toggle",
        Desc = Data.Description or nil,
        Default = Data.Default or false,
        Flag = Data.Flag or Library:NextFlag(),
        Callback = Data.Callback or Data.callback or function() end,

        Value = false
    }
    
    local Items = {}
    
    Items["Toggle"] = Instances:Create("ImageButton", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Library.Theme.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 4,
        AutomaticSize = "Y",
        Parent = Toggle.Section.Items["Content"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["Toggle"].Instance, CornerRadius = UDim.new(0, 9)})
    
    Instances:Create("UIPadding", { 
        Parent = Items["Toggle"].Instance, 
        PaddingTop = UDim.new(0, 10), 
        PaddingBottom = UDim.new(0,10),
        PaddingLeft = UDim.new(0,14), 
        PaddingRight = UDim.new(0,14)
    })

    Items["Row"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Items["Toggle"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Row"].Instance, 
        FillDirection = "Horizontal",
        Padding = UDim.new(0,12),
        HorizontalAlignment = "Left",
        VerticalAlignment = "Center",
    })
    
    Items["TitleFrame"] = Instances:Create("Frame", {
        Size = UDim2.new(1, -48, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 4,
        AutomaticSize = "Y",
        Parent = Items["Row"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["TitleFrame"].Instance, 
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,3),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    
    Items["Title"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Toggle.Name,
        TextColor3 = Library.Theme.PrimaryText,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        AutomaticSize = "Y",
        TextWrapped = true,
        Size = UDim2.new(1,0,0,15),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["TitleFrame"].Instance,
    })
    
    Items["Description"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Toggle.Desc,
        TextColor3 = Library.Theme.SecondaryText,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutomaticSize = "Y",
        TextWrapped = true,
        Visible = Toggle.Desc ~= nil and Toggle.Desc ~= "",
        Size = UDim2.new(1,0,0,13),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["TitleFrame"].Instance,
    })
    
    Items["IcoWrap"] = Instances:Create("Frame", {
        Size = UDim2.new(0, 36, 0, 36),
        BackgroundColor3 = Library.Theme.SurfaceAlt,
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Items["Row"].Instance,
    }) 
    
    Items["Indicator"] = Instances:Create("ImageLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundTransparency = 0,
        Image = "",
        BackgroundColor3 = Library.Theme.SurfaceAlt,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
        Parent = Items["IcoWrap"].Instance,
    }) Instances:Create("UICorner", { Parent = Items["Indicator"].Instance, CornerRadius = UDim.new(0, 999)})
    
    Instances:Create("UIPadding", { 
        Parent = Items["Indicator"].Instance, 
        PaddingTop = UDim.new(0, 1), 
        PaddingBottom = UDim.new(1),
        PaddingLeft = UDim.new(0,1), 
        PaddingRight = UDim.new(0,1)
    })
    
    Items["Round"] = Instances:Create("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundTransparency = 0,
        Image = "",
        BackgroundColor3 = Library.Theme.SurfaceHover,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
        Parent = Items["IcoWrap"].Instance,
    }) Instances:Create("UICorner", { Parent = Items["Round"].Instance, CornerRadius = UDim.new(0, 999)})
   
	function Toggle:SetVisibility(Bool)
        Items["Toggle"].Instance.Visible = Bool 
    end 
    
   function Toggle:Get()
        return Toggle.Value 
    end

    function Toggle:Set(Value)
        Toggle.Value = Value 
        Library.Flags[Toggle.Flag] = Value 

        if Toggle.Value then
		    Items["Round"]:Tween(nil, {Position = UDim2.new(0.5, 0, 0.5, -9), BackgroundColor3 = Library.Theme.Primary})
		else
		    Items["Round"]:Tween(nil, {Position = UDim2.new(0, 0, 0.5, -9), BackgroundColor3 = Library.Theme.SurfaceHover})
		end

        if Toggle.Callback then 
            Library:SafeCall(Toggle.Callback, Toggle.Value)
        end
    end 

    Toggle:Set(Toggle.Default)

    Library.SetFlags[Toggle.Flag] = function(Value)
        Toggle:Set(Value)
    end
    
    Items["Toggle"].Instance.MouseButton1Click:Connect(function()
        Toggle:Set(not Toggle.Value)
    end)
    
    --[[
    Items["Toggle"]:Connect("InputBegan", function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then 
            Toggle:Set(not Toggle.Value)
        end
    end)
]]

    Toggle.Section.Elements[#Toggle.Section.Elements+1] = Toggle

    return Toggle 
end

Library.Sections.Dropdown = function(self, Data)
    Data = Library.Sanitize(Data or {})

	local Dropdown = {
	    Window = self.Window,
	    Page = self.Page,
	    Section = self,
	
	    Name = Data.Name or "Dropdown",
	    Desc = Data.Description or nil,
	    Flag = Data.Flag or Library:NextFlag(),
	    Items = Data.Items or { "One", "Two", "Three" },
	    Default = Data.Default or nil,
	    Callback = Data.Callback or function() end,
	    Multi = Data.Multi or false,
	
	    Value = { },
	    Options = { },
	    OptionsWithIndexes = { },
	    IsOpen = false,
	
	    Width = 200,
	    Height = 0
	}
    
    local Items = {}
    
    Items["Dropdown"] = Instances:Create("ImageButton", {
        Size = UDim2.new(1, 0, 0, 56),
        BackgroundColor3 = Library.Theme.Surface,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        ZIndex = 4,
        AutomaticSize = "Y",
        Parent = Dropdown.Section.Items["Content"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["Dropdown"].Instance, CornerRadius = UDim.new(0, 9)})
    
    Instances:Create("UIPadding", { 
        Parent = Items["Dropdown"].Instance, 
        PaddingTop = UDim.new(0, 10), 
        PaddingBottom = UDim.new(0,10),
        PaddingLeft = UDim.new(0,14), 
        PaddingRight = UDim.new(0,14)
    })

    Items["Row"] = Instances:Create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Items["Dropdown"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["Row"].Instance, 
        FillDirection = "Horizontal",
        Padding = UDim.new(0,12),
        HorizontalAlignment = "Left",
        VerticalAlignment = "Center",
    })
    
    Items["TitleFrame"] = Instances:Create("Frame", {
        Size = UDim2.new(1, -88, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 4,
        AutomaticSize = "Y",
        Parent = Items["Row"].Instance,
    })
    
    Instances:Create("UIListLayout", { 
        Parent = Items["TitleFrame"].Instance, 
        FillDirection = Enum.FillDirection.Vertical,
        Padding = UDim.new(0,3),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
    })
    
    Items["Title"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Dropdown.Name,
        TextColor3 = Library.Theme.PrimaryText,
        Font = Enum.Font.GothamMedium,
        TextSize = 15,
        AutomaticSize = "Y",
        TextWrapped = true,
        Size = UDim2.new(1,0,0,15),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["TitleFrame"].Instance,
    })
    
	Items["Description"] = Instances:Create("TextLabel", {
        BackgroundTransparency = 1,
        Text = Dropdown.Desc,
        TextColor3 = Library.Theme.SecondaryText,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        AutomaticSize = "Y",
        Visible = Dropdown.Desc ~= nil and Dropdown.Desc ~= "",
        TextWrapped = true,
        Size = UDim2.new(1,0,0,13),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = Items["TitleFrame"].Instance,
    })
    
    Items["Trigger"] = Instances:Create("ImageButton", {
        Size = UDim2.new(0, 80, 0, 30),
        BackgroundColor3 = Library.Theme.SurfaceAlt,
        BackgroundTransparency = 1,
        ZIndex = 4,
        Parent = Items["Row"].Instance,
    }) 
    
    Items["Value"] = Instances:Create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundTransparency = 1,
        TextColor3 = Library.Theme.MutedText,
        Text = "...",
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Font = Enum.Font.Gotham,
        TextXAlignment = "Left",
        ZIndex = 5,
        Parent = Items["Trigger"].Instance,
    }) 
    Instances:Create("UICorner", { Parent = Items["Value"].Instance, CornerRadius = UDim.new(0, 5)})
    
    Instances:Create("UIPadding", { 
        Parent = Items["Value"].Instance, 
        PaddingTop = UDim.new(0, 1), 
        PaddingBottom = UDim.new(0, 1),
        PaddingLeft = UDim.new(0,1), 
        PaddingRight = UDim.new(0,1)
    })
    
    Items["Icon"] = Instances:Create("ImageLabel", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -20, 0.5, -10),
        BackgroundTransparency = 1,
        ImageColor3 = Library.Theme.MutedText,
        Image = LucideIcon["chevron-down"],
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 5,
        Parent = Items["Trigger"].Instance,
    })
    
	Items["FLOAT_dropdown"] = Instances:Create("Frame", {
		Name = "FLOAT_DROPDOWN",
		Size = UDim2.new(0, 69, 0, 69),
		Position = UDim2.new(0, 0, 0, 0),
		AnchorPoint = Vector2.new(0, 0),
		BackgroundColor3 = Library.Theme.SurfaceAlt,
		BorderSizePixel = 0,
		Active = true,
		ZIndex = 6,
		BackgroundTransparency = 0,
		Visible = false,
		Parent = Library.UnusedHolder.Instance,
	})
	
	 Instances:Create("UICorner", {
		Name = "corner",
		CornerRadius = UDim.new(0, 10),
		Parent = Items["FLOAT_dropdown"].Instance,
	})
	
	
	Items["padding"] = Instances:Create("UIPadding", {
		Name = "padding",
		PaddingTop    = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 8),
		PaddingLeft   = UDim.new(0, 10),
		PaddingRight  = UDim.new(0, 10),
		Parent = Items["FLOAT_dropdown"].Instance,
	})
	
	Items["FLOAT_TITLE"] = Instances:Create("TextLabel", {
		Name = "FLOAT_TITLE",
		Size = UDim2.new(1, 0, 0, 28),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		ZIndex = 6,
		Text = Dropdown.Name,
		BackgroundTransparency = 1,
	    TextXAlignment = "Left",
		TextColor3 = Library.Theme.PrimaryText,
		Font = Enum.Font.GothamMedium,
		TextSize = 15,
		Parent = Items["FLOAT_dropdown"].Instance,
	})
	
	
	Items["Scroll"] = Instances:Create("ScrollingFrame", {
		Name = "Scroll",
		Size = UDim2.new(1, 0, 1, -33),
		Position = UDim2.new(0, 0, 0, 33),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		ZIndex = 6,
		ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = Items["FLOAT_dropdown"].Instance,
	})
	
	Items["List"] = Instances:Create("UIListLayout", {
		Name = "List",
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 3),
		HorizontalAlignment = "Center",
		VerticalAlignment = "Top",
		Parent = Items["Scroll"].Instance,
	})
	
	Items["padding"] = Instances:Create("UIPadding", {
		Name = "padding",
		PaddingTop    = UDim.new(0, 5),
		PaddingBottom = UDim.new(0, 5),
		PaddingLeft   = UDim.new(0, 5),
		PaddingRight  = UDim.new(0, 5),
		Parent = Items["Scroll"].Instance,
	})
	
    function Dropdown:Get()
        return Dropdown.Value
    end

    function Dropdown:SetVisibility(Bool)
        Items["Dropdown"].Instance.Visible = Bool
    end

    local RenderStepped 
    local Debounce = false

    function Dropdown:SetOpen(Bool)
        if Debounce then 
            return
        end

        Dropdown.IsOpen = Bool

        Debounce = true 

        if Dropdown.IsOpen then 
            Items["FLOAT_dropdown"].Instance.Visible = true
            Items["FLOAT_dropdown"].Instance.Parent = Library.Holder.Instance

            Items["Icon"]:Tween(nil, {Rotation = 180, ImageColor3 = Color3.fromRGB(255, 255, 255)})
     
            RenderStepped = RunService.RenderStepped:Connect(function()
				local Trigger = Items["Trigger"].Instance
				local Dir = Library:ResolvePlacement(Trigger, Dropdown.Height)
				local Pos,Size = Trigger.AbsolutePosition,Trigger.AbsoluteSize
				local Y = Dir=="Down" and (Pos.Y+Size.Y+3) or (Pos.Y-Dropdown.Height-3)
				Items["FLOAT_dropdown"].Instance.AnchorPoint=Vector2.new(0,0)
				Items["FLOAT_dropdown"].Instance.Position=UDim2.new(0,Pos.X,0,Y)
				Items["FLOAT_dropdown"].Instance.Size=UDim2.new(0,Dropdown.Width,0,Dropdown.Height)
			end)

            for Index, Value in pairs(Library.OpenFrames) do 
                if Value ~= Dropdown and not Dropdown.Section.IsSettings then 
                    Value:SetOpen(false)
                end
            end

            Library.OpenFrames[Dropdown] = Dropdown 
        else
            if Library.OpenFrames[Dropdown] then 
                Library.OpenFrames[Dropdown] = nil
            end

            if RenderStepped then 
                RenderStepped:Disconnect()
                RenderStepped = nil
            end

            Items["Icon"]:Tween(nil, {Rotation = 0, ImageColor3 = Library.Theme.MutedText})
        end

        local Descendants = Items["FLOAT_dropdown"].Instance:GetDescendants()
        table.insert(Descendants, Items["FLOAT_dropdown"].Instance)

        local NewTween

        for Index, Value in ipairs(Descendants) do 
            local TransparencyProperty = Tween:GetProperty(Value)

            if not TransparencyProperty then
                continue 
            end
            
            --[[
            if not Value.ClassName:find("UI") then 
                Value.ZIndex = (Dropdown.IsOpen and Dropdown.Section.IsSettings and 8) or (Dropdown.IsOpen and 3) or 1
            end
            ]]
            
            if type(TransparencyProperty) == "table" then 
                for _, Property in ipairs(TransparencyProperty) do 
                    NewTween = Tween:FadeItem(Value, Property, Bool, Library.FadeSpeed)
                end
            else
                NewTween = Tween:FadeItem(Value, TransparencyProperty, Bool, Library.FadeSpeed)
            end
        end
        
        if NewTween and NewTween.Tween then
            NewTween.Tween.Completed:Connect(function()
                Debounce = false 
                Items["FLOAT_dropdown"].Instance.Visible = Dropdown.IsOpen
                task.wait(0.2)
                Items["FLOAT_dropdown"].Instance.Parent = not Dropdown.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
            end)
        else
            Debounce = false
            Items["FLOAT_dropdown"].Instance.Visible = Dropdown.IsOpen
            Items["FLOAT_dropdown"].Instance.Parent = not Dropdown.IsOpen and Library.UnusedHolder.Instance or Library.Holder.Instance
        end
    end

    function Dropdown:Set(Option)
        if Dropdown.Multi then 
            if type(Option) ~= "table" then 
                return
            end

            Dropdown.Value = Option
            Library.Flags[Dropdown.Flag] = Option

            for _, OptionData in pairs(Dropdown.Options) do
                OptionData.Selected = false 
                OptionData:Toggle(false)
            end

            for Index, Value in ipairs(Option) do
                local OptionData = Dropdown.Options[Value]
                
                if not OptionData then
                    continue
                end

                OptionData.Selected = true 
                OptionData:Toggle(true)
            end

            local TextFormat = #Dropdown.Value > 0 and TableConcat(Dropdown.Value, ", ") or "..."
            Items["Value"].Instance.Text = TextFormat
        else
            if not Dropdown.Options[Option] then
                return
            end

            local OptionData = Dropdown.Options[Option]

            Dropdown.Value = Option
            Library.Flags[Dropdown.Flag] = Option

            for Name, Value in pairs(Dropdown.Options) do
                if Value ~= OptionData then
                    Value.Selected = false 
                    Value:Toggle(false)
                else
                    Value.Selected = true 
                    Value:Toggle(true)
                end
            end

            Items["Value"].Instance.Text = Option
        end

        if Dropdown.Callback then   
            Library:SafeCall(Dropdown.Callback, Dropdown.Value)
        end
    end

    function Dropdown:Add(Option)

		Items["OptionButton"] = Instances:Create("ImageButton", {
			Name = "OptionButton",
			Size = UDim2.new(1, 0, 0, 32),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Library.Theme.SurfaceAlt,
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			Image = "rbxassetid://123456789",
			ImageTransparency = 0,
			ZIndex = 8,
			BackgroundTransparency = 1,
			Parent = Items["Scroll"].Instance,
		})
		
		Items["corner"] = Instances:Create("UICorner", {
			Name = "corner",
			CornerRadius = UDim.new(0, 10),
			Parent = Items["OptionButton"].Instance,
		})
		
		Items["horizontal"] = Instances:Create("UIListLayout", {
			FillDirection = "Horizontal",
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 5),
			HorizontalAlignment = "Left",
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Parent = Items["OptionButton"].Instance,
		})
		
		Items["OptionTitle"] = Instances:Create("TextLabel", {
			Name = "OptionTitle",
			Size = UDim2.new(1, -25, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Text = Option,
			ZIndex = 10,
			BackgroundTransparency = 1,
			TextColor3 = Library.Theme.MutedText,
			Font = Enum.Font.GothamMedium,
			TextSize = 14,
			TextXAlignment= "Left",
			Parent = Items["OptionButton"].Instance,
		})	
		
		Items["Checked"] = Instances:Create("ImageLabel", {
			Name = "checked",
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(1, -36, 0.5, 0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			ImageColor3 = Library.Theme.Primary,
			Image = LucideIcon["check"],
			ImageTransparency = 1,
			ZIndex = 8,
			ScaleType = Enum.ScaleType.Stretch,
			BackgroundTransparency = 1,
			Parent = Items["OptionButton"].Instance,
		})
    
    
        local OptionData = {
            Button = Items["OptionButton"].Instance,
            Name = Option,
            OptionText = Items["OptionTitle"],
            Checked = Items["Checked"],
            Selected = false
        }
        
		function OptionData:Toggle(Bool)
		    if Dropdown.Multi then
		        if Bool then
		            OptionData.OptionText:Tween(nil,{TextColor3=Library.Theme.Primary,TextTransparency=0})
		            OptionData.Checked:Tween(nil,{ImageTransparency=0})
		        else
		            OptionData.OptionText:Tween(nil,{TextColor3=Library.Theme.MutedText,TextTransparency=0})
		            OptionData.Checked:Tween(nil,{ImageTransparency=1})
		        end
		    else
		        if Bool then
		            OptionData.OptionText:Tween(nil,{TextColor3=Library.Theme.Primary,TextTransparency=0})
		        else
		            OptionData.OptionText:Tween(nil,{TextColor3=Library.Theme.MutedText,TextTransparency=0})
		        end
		        OptionData.Checked:Tween(nil,{ImageTransparency=1})
		    end
		end

        function OptionData:Set()
            OptionData.Selected = not OptionData.Selected

            if Dropdown.Multi then 
                local Index = table.find(Dropdown.Value, OptionData.Name)

                if Index then 
                    table.remove(Dropdown.Value, Index)
                else
                    table.insert(Dropdown.Value, OptionData.Name)
                end

                OptionData:Toggle(not Index)

                Library.Flags[Dropdown.Flag] = Dropdown.Value

                local TextFormat = #Dropdown.Value > 0 and table.concat(Dropdown.Value, ", ") or "..."
                Items["Value"].Instance.Text = TextFormat
            else
                for _, Value in pairs(Dropdown.Options) do
                    if Value ~= OptionData then
                        Value.Selected = false 
                        Value:Toggle(false)
                    end
                end

                if OptionData.Selected then 
                    Dropdown.Value = OptionData.Name
                    Library.Flags[Dropdown.Flag] = OptionData.Name

                    OptionData.Selected = true
                    OptionData:Toggle(true)
                    Items["Value"].Instance.Text = OptionData.Name
                else
                    Dropdown.Value = nil
                    Library.Flags[Dropdown.Flag] = nil

                    OptionData.Selected = false
                    OptionData:Toggle(false)
                    Items["Value"].Instance.Text = "..."
                end
            end

            if Dropdown.Callback then
                Library:SafeCall(Dropdown.Callback, Dropdown.Value)
            end
        end

        Items["OptionButton"].Instance.MouseButton1Click:Connect(function()
            OptionData:Set()
        end)

        Dropdown.Options[OptionData.Name] = OptionData
        table.insert(Dropdown.OptionsWithIndexes, OptionData)

        Dropdown.Height = 51 + Items["List"].Instance.AbsoluteContentSize.Y
        return OptionData
    end

    function Dropdown:Remove(Option)
        if Dropdown.Options[Option] then
            local OptionData = Dropdown.Options[Option]
            if OptionData.Button then
                OptionData.Button:Destroy()
            end
            Dropdown.Options[Option] = nil
            
            for i, v in ipairs(Dropdown.OptionsWithIndexes) do
                if v.Name == Option then
                    table.remove(Dropdown.OptionsWithIndexes, i)
                    break
                end
            end
            
			Dropdown.Height = 51 + Items["List"].Instance.AbsoluteContentSize.Y
        end
    end

    function Dropdown:Refresh(List, DefaultVal)
        local OptionsToRemove = {}
        for Name, _ in pairs(Dropdown.Options) do
            table.insert(OptionsToRemove, Name)
        end
        for _, Name in ipairs(OptionsToRemove) do
            Dropdown:Remove(Name)
        end
        
        Dropdown.Options = {}
        Dropdown.OptionsWithIndexes = {}
        
        for Index, Value in ipairs(List) do
            Dropdown:Add(Value)
        end
        
        if DefaultVal then
            Dropdown:Set(DefaultVal)
        else
            Dropdown.Value = Dropdown.Multi and {} or nil
            Library.Flags[Dropdown.Flag] = Dropdown.Value
            Items["Value"].Instance.Text = Dropdown.Multi and "" or "..."
        end
    end

    Items["Trigger"].Instance.MouseButton1Click:Connect(function()
        Dropdown:SetOpen(not Dropdown.IsOpen)
    end)

    Library:Connect(UserInputService.InputBegan, function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            if Dropdown.IsOpen then
                if Library:IsMouseOverFrame(Items["FLOAT_dropdown"]) then
                    return
                end
                Dropdown:SetOpen(false)
            end
        end
    end)

    Items["Trigger"].Instance:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
        if Dropdown.IsOpen then
            Dropdown.IsOpen = not Library:IsClipped(Items["FLOAT_dropdown"].Instance, Dropdown.Section.Items["Section"].Instance.Parent)
            Items["FLOAT_dropdown"].Instance.Visible = Dropdown.IsOpen
        end
    end)

    for Index, Value in ipairs(Dropdown.Items) do 
        Dropdown:Add(Value)
    end

    if Dropdown.Default then 
        Dropdown:Set(Dropdown.Default)
    else
        Dropdown.Value = Dropdown.Multi and {} or nil
        Library.Flags[Dropdown.Flag] = Dropdown.Value
        Items["Value"].Instance.Text = Dropdown.Multi and "" or "..."
    end

    Library.SetFlags[Dropdown.Flag] = function(Value)
        Dropdown:Set(Value)
    end

    table.insert(Dropdown.Section.Elements, Dropdown)
    return Dropdown
end
end       

getgenv().Library = Library

return Library
