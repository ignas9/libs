local Library
local TweenService = game:GetService("TweenService")
local function Resize (part,new,_delay)
	_delay = _delay or 0.5
	local tweenInfo = TweenInfo.new(_delay, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(part, tweenInfo, new)
	tween:Play()
end
local function CreateDrag(gui)
	local UserInputService = game:GetService("UserInputService")
	local dragging
	local dragInput
	local dragStart
	local startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		Resize(gui, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.16)
	end
	
	gui.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = gui.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	gui.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end
do -- UI Library 

	--// Services \\--
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local CoreGui = RunService:IsStudio() and game:GetService("Players").LocalPlayer.PlayerGui or game:GetService("CoreGui")

	--// Functions \\--
	local BlacklistedKeys = { --add or remove keys if you find the need to
		Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.One,Enum.KeyCode.Two,Enum.KeyCode.Three,Enum.KeyCode.Four,Enum.KeyCode.Five,Enum.KeyCode.Six,Enum.KeyCode.Seven,Enum.KeyCode.Eight,Enum.KeyCode.Nine,Enum.KeyCode.Zero,Enum.KeyCode.Escape,Enum.KeyCode.F1,Enum.KeyCode.F2,Enum.KeyCode.F3,Enum.KeyCode.F4,Enum.KeyCode.F5,Enum.KeyCode.F6,Enum.KeyCode.F7,Enum.KeyCode.F8,Enum.KeyCode.F9,Enum.KeyCode.F10,Enum.KeyCode.F11,Enum.KeyCode.F12
	}

	local WhitelistedMouseInputs = { --add or remove mouse inputs if you find the need to
		Enum.UserInputType.MouseButton1,Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3
	}

	local function keyCheck(x,x1)
		for _,v in next, x1 do
			if v == x then 
				return true
			end 
		end
	end

	local function Round(num, bracket)
		bracket = bracket or 1
		local a = math.floor(num/bracket + (math.sign(num) * 0.5)) * bracket
		if a < 0 then
			a = a + bracket
		end
		return a
	end

	local function AddHighlight(obj)
		local InContact
		obj.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				InContact = true
				TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				TweenService:Create(obj, TweenInfo.new(0.4), {BackgroundTransparency = 0.8}):Play()
			end
		end)
		obj.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				InContact = false
				TweenService:Create(obj, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 and InContact then
				TweenService:Create(obj, TweenInfo.new(0.2), {BackgroundTransparency = 0.9}):Play()
			end
		end)
	end

	local DDCheck
	local ExtFrames = {}
	local function CloseExt()
		if not DDCheck then return end
		DDCheck.Closed = true
		DDCheck.Container.Size = UDim2.new(DDCheck.Container.Size.X.Scale, DDCheck.Container.Size.X.Offset, 0, 0)
		if DDCheck.Closed then DDCheck.Main.Parent.Parent.ClipsDescendants = true end
		if DDCheck.Arrow then
			DDCheck.Arrow.Text = ">"
		end
		for _,v in next, ExtFrames do
			v.Parent = nil
		end
		DDCheck = nil
	end
	for i=1,4 do
		local Frame = Instance.new("Frame")
		Frame.ZIndex = 50
		Frame.BackgroundTransparency = 1
		Frame.Visible = true
		if i == 1 then
			Frame.Size = UDim2.new(0,1000,0,-1000)
		elseif i == 2 then
			Frame.Size = UDim2.new(0,1000,0,1000)
			Frame.Position = UDim2.new(1,0,0,0)
		elseif i == 3 then
			Frame.Size = UDim2.new(0,-1000,0,1000)
			Frame.Position = UDim2.new(1,0,1,0)
		elseif i == 4 then
			Frame.Size = UDim2.new(0,-1000,0,-1000)
			Frame.Position = UDim2.new(0,0,1,0)
		end
		table.insert(ExtFrames, Frame)
		Frame.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				CloseExt()
			end
		end)
	end

	local function CloseWindow(Obj)
		for _,v in next, ExtFrames do
			DDCheck = Obj
			v.Parent = Obj.Container
		end
	end

	local ChromaColor
	spawn(function()
		local a = 0
		while wait() do
			ChromaColor = Color3.fromHSV(a,1,1)
			a = a >= 1 and 0 or a + 0.01
		end
	end)

	--LIBRARY
	Library = {Tabs = {}, FocusedTab = nil, Open = true}

	Library.settings = {
		UiToggle = Enum.KeyCode.RightShift,
		Theme = Color3.fromRGB(255,65,65)
	}

	UserInputService.InputBegan:connect(function(input)
		if input.KeyCode == Library.settings.UiToggle and Library.Base then
			Library.Open = not Library.Open
			if Library.FocusedTab then
				if Library.Open then
					Library.Base.Enabled = true
					for _,Tab in next, Library.Tabs do
						Tab.ButtonHolder.Visible = Tab.Visible
					end
				else
					CloseExt()
					for _,Tab in next, Library.Tabs do
						Tab.ButtonHolder.Visible = false
					end
					Library.Base.Enabled = false
				end
			end
		end
	end)

	UserInputService.InputChanged:connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and Library.Pointer then
			local Mouse = UserInputService:GetMouseLocation() + Vector2.new(0,-36)
			Library.Pointer.Position = UDim2.new(0,Mouse.X,0,Mouse.Y)
		end
	end)

	function Library:Create(class, properties)
		local inst = Instance.new(class)
		for property, value in pairs(properties) do
			inst[property] = value
		end
		return inst
	end

	function Library:CreateTab(TabName)
		local Tab = {Sections = {}, Visible = true}
		
		self.Base = self.Base or self:Create("ScreenGui", {
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
			Parent = CoreGui
		})
		
		self.Line = self.Line or self:Create("Frame", {
			AnchorPoint = Vector2.new(0.5,0),
			Position = UDim2.new(0.5,0,1,0),
			Size = UDim2.new(0,0,0,-2),
			BackgroundColor3 = Library.settings.Theme,
			BorderSizePixel = 0
		})
		
		self.Pointer = self.Pointer or self:Create("Frame", {
			ZIndex = 100,
			AnchorPoint = Vector2.new(0,0),
			Size = UDim2.new(0,4,0,4),
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			Parent = self.Base
		})
		
		self.PointerDot = self.PointerDot or self:Create("Frame", {
			ZIndex = 100,
			Size = UDim2.new(0,2,0,2),
			BackgroundColor3 = Library.settings.Theme,
			BorderSizePixel = 0,
			Parent = self.Pointer
		})
		
		Tab.XPos = 5 + (#self.Tabs * 205)
		
		Tab.ButtonHolder = self:Create("Frame", {
			Position = UDim2.new(0,Tab.XPos,0,5),
			Size = UDim2.new(0,200,0,28),
			BackgroundColor3 = Color3.fromRGB(40,40,40),
			BorderSizePixel = 0,
			Parent = self.Base
		})
		
		Tab.Button = self:Create("TextButton", {
			Size = UDim2.new(1,0,1,0),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			BorderSizePixel = 0,
			Text = TabName,
			TextSize = 18,
			TextColor3 = Color3.fromRGB(255,255,255),
			Font = Enum.Font.SourceSans,
			AutoButtonColor = false,
			Modal = true,
			Parent = Tab.ButtonHolder
		})
		
		Tab.Main = self:Create("Frame", {
			ZIndex = -10,
			Position = UDim2.new(0,0,0,-36),
			Size = UDim2.new(1,0,1,36),
			BackgroundTransparency = 1,
			BackgroundColor3 = Color3.new(),
			Visible = false,
			Parent = self.Base
		})
		
		AddHighlight(Tab.Button)
		
		self.FocusOnTab = self.FocusOnTab or function(t)
			if self.FocusedTab then
				self.FocusedTab.Main.Visible = false
			end
			self.FocusedTab = t
			self.FocusedTab.Main.Visible = true
		end
		
		Tab.Button.MouseButton1Click:connect(function()
			if self.FocusedTab ~= Tab then
				if DDCheck then
					DDCheck.Main.Parent.Parent.ClipsDescendants = true
				end
				self.FocusOnTab(Tab)
			end
		end)
		
		if not self.FocusedTab then
			self.FocusOnTab(Tab)
		end
		
		function Tab:AddSection(SectionName)
			local Section = {Options = {}}
			Section.YSize = 24
			
			Section.Main = Library:Create("Frame", {
				Position = UDim2.new(0,5 + (#self.Sections * 205),0,74),
				Size = UDim2.new(0,200,0,24),
				BackgroundColor3 = Color3.fromRGB(20,20,20),
				BorderSizePixel = 0,
				ClipsDescendants = true,
				Parent = self.Main
			})
			
			Section.Label = Library:Create("TextLabel", {
				Size = UDim2.new(1,0,0,24),
				BackgroundColor3 = Color3.fromRGB(30,30,30),
				BorderSizePixel = 0,
				Text = SectionName,
				TextSize = 16,
				TextColor3 = Color3.fromRGB(255,255,255),
				Font = Enum.Font.SourceSans,
				Parent = Section.Main
			})
			
			Section.Content = Library:Create("Frame", {
				Position = UDim2.new(0,0,0,24),
				Size = UDim2.new(1,0,1,-24),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = Section.Main
			})
			
			Section.Layout = Library:Create("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Parent = Section.Content
			})
			
			function Section:AddLabel(LabelText)
				local Label = {}
				
				Label.Main = Library:Create("TextLabel", {
					LayoutOrder = #self.Options + 1,
					Size = UDim2.new(1,0,0,22),
					BackgroundTransparency = 1,
					Text = " "..LabelText,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					TextXAlignment = Enum.TextXAlignment.Left,
					Parent = self.Content
				})
				
				Section.YSize = Section.YSize + 22
				Section.Main.Size = UDim2.new(0,200,0,Section.YSize)
				table.insert(self.Options, Label)
				return Label
			end
			
			function Section:AddButton(ButtonText, Callback)
				local Button = {}
				Callback = Callback or function() end
				
				Button.Main = Library:Create("TextButton", {
					LayoutOrder = #self.Options + 1,
					Size = UDim2.new(1,0,0,22),
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(220,220,220),
					BorderSizePixel = 0,
					Text = " "..ButtonText,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
					Parent = self.Content
				})
				
				AddHighlight(Button.Main)
				
				Button.Main.MouseButton1Click:connect(function()
					Callback()
				end)
				
				Section.YSize = Section.YSize + 22
				Section.Main.Size = UDim2.new(0,200,0,Section.YSize)
				table.insert(self.Options, Button)
				return Button
			end
			
			function Section:AddToggle(ToggleText, Callback)
				local Toggle = {State = false, Callback = Callback}
				Toggle.Callback = Callback or function() end
				
				Toggle.Main = Library:Create("TextButton", {
					LayoutOrder = #self.Options + 1,
					Size = UDim2.new(1,0,0,22),
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(220,220,220),
					BorderSizePixel = 0,
					Text = " "..ToggleText,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
					Parent = self.Content
				})
				
				Toggle.Visualize = Library:Create("Frame", {
					Position = UDim2.new(1,-2,0,2),
					Size = UDim2.new(0,-18,0,18),
					BackgroundColor3 = Color3.fromRGB(35,35,35),
					BorderSizePixel = 0,
					Parent = Toggle.Main
				})
				
				AddHighlight(Toggle.Main)
				
				local on = TweenService:Create(Toggle.Visualize, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Library.settings.Theme})
				local off = TweenService:Create(Toggle.Visualize, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(35,35,35)})
				
				function Toggle:SetToggle(State)
					Toggle.State = State
					if Toggle.State then
						on:Play()
					else
						off:Play()
					end
					Toggle.Callback(Toggle.State)
				end
				
				Toggle.Main.MouseButton1Click:connect(function()
					Toggle:SetToggle(not Toggle.State)
				end)
				
				Section.YSize = Section.YSize + 22
				Section.Main.Size = UDim2.new(0,200,0,Section.YSize)
				table.insert(self.Options, Toggle)
				return Toggle
			end
			
			function Section:AddBox(BoxText, Callback)
				local Box = {Callback = Callback}
				Box.Callback = Callback or function() end
				
				Box.Main = Library:Create("TextButton", {
					LayoutOrder = #self.Options + 1,
					Size = UDim2.new(1,0,0,42),
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(220,220,220),
					BorderSizePixel = 0,
					Text = " "..BoxText,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					AutoButtonColor = false,
					Parent = self.Content
				})
				
				Box.Box = Library:Create("TextBox", {
					Position = UDim2.new(0,2,0,20),
					Size = UDim2.new(1,-4,0,20),
					BackgroundColor3 = Color3.fromRGB(35,35,35),
					BorderSizePixel = 0,
					Text = "",
					TextColor3 = Color3.fromRGB(240,240,240),
					ClipsDescendants = true,
					Parent = Box.Main
				})
				
				AddHighlight(Box.Main)
				
				Box.Main.MouseButton1Click:connect(function()
					Box.Box:CaptureFocus()
				end)
				
				Box.Box.FocusLost:connect(function(EnterPressed)
					TweenService:Create(Box.Main, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
					Box.Callback(Box.Box.Text, EnterPressed)
				end)
				
				Section.YSize = Section.YSize + 42
				Section.Main.Size = UDim2.new(0,200,0,Section.YSize)
				table.insert(self.Options, Box)
				return Box
			end
			
			function Section:AddDropdown(DropdownText, Options, Callback, Groupbox)
				if Options then
					if typeof(Options) == "function" then
						Callback = Options
						Options = {}
					end
					if typeof(Options) == "boolean" then
						Groupbox = Options
						Callback = typeof(Options) == "function" and Options or function() end
						Options = {}
					end
				end
				if Callback and typeof(Callback) == "boolean" then
					Groupbox = Callback
					Callback = function() end
				end
				local Dropdown = {Order = 0, Closed = true, Value = Groupbox and nil or Options[1], Callback = Callback, Selected = {}}
				Dropdown.Callback = Callback or function() end
				
				Dropdown.Main = Library:Create("TextButton", {
					LayoutOrder = #self.Options + 1,
					Size = UDim2.new(1,0,0,42),
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(220,220,220),
					BorderSizePixel = 0,
					Text = " "..DropdownText,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					AutoButtonColor = false,
					Parent = self.Content
				})
				
				Dropdown.Label = Library:Create("TextLabel", {
					Position = UDim2.new(0,2,0,20),
					Size = UDim2.new(1,-4,0,20),
					BackgroundColor3 = Color3.fromRGB(35,35,35),
					BorderSizePixel = 0,
					Text = Groupbox and "" or Dropdown.Value,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					TextTruncate = Enum.TextTruncate.AtEnd,
					Font = Enum.Font.SourceSans,
					Parent = Dropdown.Main
				})
				
				Dropdown.Arrow = Library:Create("TextLabel", {
					Position = UDim2.new(1,0,0,2),
					Size = UDim2.new(0,-16,0,16),
					Rotation = 90,
					BackgroundTransparency = 1,
					Text = ">",
					TextColor3 = Color3.fromRGB(80,80,80),
					Font = Enum.Font.Arcade,
					TextSize = 18,
					Parent = Dropdown.Label
				})
				
				Dropdown.Container = Library:Create("Frame", {
					ZIndex = 2,
					Position = UDim2.new(0,0,1,2),
					Size = UDim2.new(1,0,0,0),
					BackgroundTransparency = 1,
					Parent = Dropdown.Label
				})
				
				Dropdown.SubContainer = Library:Create("Frame", {
					Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Parent = Dropdown.Container
				})
				
				Dropdown.Contentholder = Library:Create("ScrollingFrame", {
					ZIndex = 2,
					Size = UDim2.new(1,0,1,0),
					BackgroundColor3 = Color3.fromRGB(40,40,40),
					BorderColor3 = Color3.fromRGB(30,30,30),
					ScrollBarThickness = 6,
					ScrollBarImageColor3 = Color3.fromRGB(80,80,80),
					BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
					TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
					Parent = Dropdown.SubContainer
				})
				
				Dropdown.Layout = Library:Create("UIListLayout", {
					Padding = UDim.new(0,0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					Parent = Dropdown.Contentholder
				})
				
				AddHighlight(Dropdown.Main)
				
				Dropdown.Main.InputBegan:connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dropdown.Closed = not Dropdown.Closed
						if Dropdown.Closed then
							Dropdown.Arrow.Text = ">"
							Dropdown.Container:TweenSize(UDim2.new(1,0,0,0), "Out", "Quad", 0.2, true, function() if Dropdown.Closed then self.Main.ClipsDescendants = true end end)
						else
							CloseWindow(Dropdown)
							self.Main.ClipsDescendants = false
							Dropdown.Arrow.Text = "<"
							if Dropdown.Order > 5 then
								Dropdown.Container:TweenSize(UDim2.new(1,0,0,5*20), "Out", "Quad", 0.3, true)
							else
								Dropdown.Container:TweenSize(UDim2.new(1,0,0,Dropdown.Order*20), "Out", "Quad", 0.3, true)
							end
						end
					end
				end)
				
				local SelectedCount = 0
				local function AddOptions(Options)
					for _,value in pairs(Options) do
						Dropdown.Order = Dropdown.Order + 1
						local State
						local Pos = Dropdown.Order
						
						local Option = Library:Create("TextButton", {
							ZIndex = 3,
							LayoutOrder = Dropdown.Order,
							Size = UDim2.new(1,0,0,20),
							BackgroundTransparency = 1,
							BackgroundColor3 = Color3.fromRGB(255,255,255),
							Text = value,
							TextSize = 16,
							TextColor3 = Color3.fromRGB(240,240,240),
							Font = Enum.Font.SourceSans,
							AutoButtonColor = false,
							Parent = Dropdown.Contentholder
						})
						
						AddHighlight(Option)
						
						Option.MouseButton1Click:connect(function()
							Dropdown.Value = value
							if Groupbox then
								State = not State
								SelectedCount = SelectedCount + (State and 1 or -1)
								if State then
									Option.BackgroundColor3 = Library.settings.Theme
									Dropdown.Selected[value] = value
								else
									Option.BackgroundColor3 = Color3.fromRGB(255,255,255)
									Dropdown.Selected[value] = nil
								end
								local Text = ""
								for _,v in next, Dropdown.Selected do
									Text = SelectedCount > 1 and Text .. v .. ", " or Text .. v
								end
								Dropdown.Label.Text = SelectedCount > 1 and string.sub(Text, 1, string.len(Text) - 2) or Text
								if not State then return end
							else
								self.Main.ClipsDescendants = true
								Dropdown.Label.Text = Dropdown.Value
								Dropdown.Closed = true
								Dropdown.Arrow.Text = ">"
								Dropdown.Container:TweenSize(UDim2.new(1,0,0,0), "Out", "Quad", 0.2, true)
							end
							Dropdown.Callback(Dropdown.Value)
						end)
						Dropdown.Contentholder.CanvasSize = UDim2.new(0,0,0,Dropdown.Order*20)
					end
				end
				
				AddOptions(Options)

				if Groupbox then
					function Dropdown:IsSelected(Value)
						for _, v in next, self.Selected do
							if v == Value then
								return true
							end
						end
						return false
					end
				end
				
				function Dropdown:Refresh(options, keep)
					if not keep then
						Dropdown.Selected = {}
						Dropdown.Label.Text = Groupbox and "" or options[1]
						for _,v in pairs(Dropdown.Contentholder:GetChildren()) do
							if v:IsA"TextButton" then
								v:Destroy()
								Dropdown.Order = Dropdown.Order - 1
								Dropdown.Contentholder.CanvasSize = UDim2.new(0,0,0,Dropdown.Layout.AbsoluteContentSize.Y)
							end
						end
					end
					AddOptions(options)
				end
				
				if not Groupbox then
					function Dropdown:SetValue(value)
						Dropdown.Value = value
						Dropdown.Label.Text = Dropdown.Value
						Dropdown.Callback(Dropdown.Value)
					end
				end
				
				Section.YSize = Section.YSize + 42
				Section.Main.Size = UDim2.new(0,200,0,Section.YSize)
				table.insert(self.Options, Dropdown)
				return Dropdown
			end
			
			function Section:AddKeybind(BindText, BindKey, Callback, Hold)
				if BindKey then
					if typeof(BindKey) == "function" then
						Hold = Callback or false
						Callback = BindKey
						BindKey = Enum.KeyCode.F
					end
					if typeof(BindKey) == "string" then
						if not keyCheck(Enum.KeyCode[BindKey:upper()], BlacklistedKeys) then
							BindKey = Enum.KeyCode[BindKey:upper()]
						end
						if keyCheck(BindKey, WhitelistedMouseInputs) then
							BindKey = Enum.UserInputType[BindKey:upper()]
						end
					end
					if typeof(BindKey) == "boolean" then
						Hold = BindKey
						BindKey = Enum.KeyCode.F
					end
				end
				local Bind = {Binding = false, Holding = false, Key = BindKey, Hold = Hold, Callback = Callback}
				Bind.Callback = Callback or function() end
				
				local Bounds = game:GetService('TextService'):GetTextSize(Bind.Key.Name, 16, Enum.Font.SourceSans, Vector2.new(math.huge, math.huge))
				Bind.Main = Library:Create("TextButton", {
					LayoutOrder = #self.Options + 1,
					Size = UDim2.new(1,0,0,22),
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(220,220,220),
					Text = " "..BindText,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
					Parent = self.Content
				})
				
				Bind.Label = Library:Create("TextLabel", {
					Position = UDim2.new(1,-2,0,2),
					Size = UDim2.new(0,-Bounds.X-8,0,18),
					BackgroundColor3 = Color3.fromRGB(35,35,35),
					BorderSizePixel = 0,
					Text = Bind.Key.Name,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					Parent = Bind.Main
				})
				
				AddHighlight(Bind.Main)
				
				Bind.Main.InputBegan:connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Bind.Label.Text = "..."
						Bind.Label.Size = UDim2.new(0,-Bind.Label.TextBounds.X-8,1,-4)
					end
				end)
				
				Bind.Main.InputEnded:connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Bind.Binding = true
					end
				end)
				
				local function SetKey(key)
					Bind.Key = key
					Bind.Label.Text = Bind.Key.Name
					if string.match(tostring(key), "Mouse") then
						Bind.Label.Text = string.sub(tostring(key), 20, 24)..string.sub(tostring(key), 31, 32)
					end
					Bind.Label.Size = UDim2.new(0,-Bind.Label.TextBounds.X-8,1,-4)
					Bind.Callback(Bind.Key)
				end
				
				local Loop
				local function DisconnectLoop()
					if Loop then
						Loop:Disconnect()
						Bind.Callback(true)
					end
				end

				UserInputService.InputBegan:connect(function(input)
					if Bind.Binding then
						if input.KeyCode == Enum.KeyCode.Backspace then
							SetKey(Bind.Key)
							Bind.Binding = false
						else
							if not keyCheck(input.KeyCode, BlacklistedKeys) then
								SetKey(input.KeyCode)
								Bind.Binding = false
							end
							if keyCheck(input.UserInputType, WhitelistedMouseInputs) then
								SetKey(input.UserInputType)
								Bind.Binding = false
							end
						end
						DisconnectLoop()
					else
						if not Library.Open then
							if input.KeyCode.Name == Bind.Key.Name or input.UserInputType.Name == Bind.Key.Name then
								Bind.Holding = true
								if Bind.Hold then
									Loop = RunService.RenderStepped:connect(function()
										Bind.Callback()
										if Library.Open or Bind.Holding == false or not Bind.Hold then
											DisconnectLoop()
										end
									end)
								else
									Bind.Callback()
								end
							end
						end
					end
				end)
				
				UserInputService.InputEnded:connect(function(input)
					if input.KeyCode.Name == Bind.Key.Name or input.UserInputType.Name == Bind.Key.Name then
						Bind.Holding = false
						DisconnectLoop()
					end
				end)
				
				function Bind:SetKeybind(Key)
					if typeof(Key) == "string" then
						if not keyCheck(Enum.KeyCode[Key:upper()], BlacklistedKeys) then
							Key = Enum.KeyCode[Key:upper()]
						end
						if keyCheck(Enum.KeyCode[Key:upper()], WhitelistedMouseInputs) then
							Key = Enum.UserInputType[Key:upper()]
						end
					end
					DisconnectLoop()
					SetKey(Key)
				end
				
				Section.YSize = Section.YSize + 22
				Section.Main.Size = UDim2.new(0,200,0,Section.YSize)
				table.insert(self.Options, Bind)
				return Bind
			end
			
			function Section:AddSlider(SliderText, MinVal, MaxVal, SetVal, Callback, Float)
				if SetVal and typeof(SetVal) == "function" then
					Float = Callback
					Callback = SetVal
					SetVal = 0
				end
				if Callback and typeof(Callback) == "number" then
					Float = Callback
					Callback = function() end
				end
				SetVal = SetVal or 0
				if SetVal > MaxVal then
					SetVal = MaxVal
				end
				if SetVal < MinVal then
					SetVal = MinVal
				end
				local Slider = {Value = SetVal, Callback = Callback}
				Slider.Callback = Callback or function() end
				Float = Float or 1
				
				Slider.Main = Library:Create("TextButton", {
					LayoutOrder = #self.Options + 1,
					Size = UDim2.new(1,0,0,42),
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(220,220,220),
					Text = " "..SliderText,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					AutoButtonColor = false,
					Parent = self.Content
				})
				
				Slider.Holder = Library:Create("Frame", {
					Position = UDim2.new(0,0,0,18),
					Size = UDim2.new(1,0,0,17),
					BackgroundTransparency = 1,
					Parent = Slider.Main
				})
				
				Slider.Visualize = Library:Create("TextBox", {
					Position = UDim2.new(0,0,0.6,0),
					Size = UDim2.new(1,0,0.4,0),
					BackgroundTransparency = 1,
					Text = Slider.Value,
					TextSize = 16,
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					TextWrapped = true,
					Parent = Slider.Holder
				})
				
				Slider.Bar = Library:Create("Frame", {
					AnchorPoint = Vector2.new(0.5,0.5),
					Position = UDim2.new(0.5,0,0.2,0),
					Size = UDim2.new(1,-6,0,2),
					BackgroundColor3 = Color3.fromRGB(35,35,35),
					BorderSizePixel = 0,
					Parent = Slider.Holder
				})
				
				Slider.Fill = Library:Create("Frame", {
					BackgroundColor3 = Library.settings.Theme,
					BorderSizePixel = 0,
					Parent = Slider.Bar
				})
				if MinVal >= 0 then
					Slider.Fill.Size = UDim2.new((SetVal - MinVal) / (MaxVal - MinVal),0,1,0)
				else
					Slider.Fill.Position = UDim2.new((0 - MinVal) / (MaxVal - MinVal),0,0,0)
					Slider.Fill.Size = UDim2.new(SetVal / (MaxVal - MinVal),0,1,0)
				end
				
				Slider.Box = Library:Create("Frame", {
					AnchorPoint = Vector2.new(0.5,0.5),
					Position = UDim2.new((SetVal - MinVal) / (MaxVal - MinVal),0,0.5,0),
					Size = UDim2.new(0,4,0,12),
					BackgroundColor3 = Color3.fromRGB(5,5,5),
					BorderSizePixel = 0,
					Parent = Slider.Bar
				})
				
				AddHighlight(Slider.Main)
				
				function Slider:SetValue(Value)
					Value = Round(Value, Float)
					if Value >= MaxVal then
						Value = MaxVal
					end
					if Value <= MinVal then
						Value = MinVal
					end
					Slider.Box.Position = UDim2.new((Value - MinVal) / (MaxVal - MinVal),0,0.5,0)
					if MinVal >= 0 then
						Slider.Fill.Size = UDim2.new((Value - MinVal) / (MaxVal - MinVal),0,1,0)
					else
						Slider.Fill.Size = UDim2.new(Value / (MaxVal - MinVal),0,1,0)
					end
					Slider.Value = Value
					Slider.Visualize.Text = Value
					Slider.Callback(Value)
				end
				
				local Sliding
				local Modifying
				Slider.Main.InputBegan:connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
							Modifying = true
							Slider.Visualize:CaptureFocus()
						else
							Sliding = true
							Slider:SetValue(MinVal + ((input.Position.X - Slider.Bar.AbsolutePosition.X) / Slider.Bar.AbsoluteSize.X) * (MaxVal - MinVal))
							input.Changed:connect(function()
								if input.UserInputState == Enum.UserInputState.End then
									Sliding = false
								end
							end)
						end
					end
				end)
				
				Slider.Visualize.Focused:connect(function()
					if not Modifying then
						Slider.Visualize:ReleaseFocus()
					end
				end)
				
				Slider.Visualize.FocusLost:connect(function()
					if Modifying then
						if tonumber(Slider.Visualize.Text) then
							Slider:SetValue(tonumber(Slider.Visualize.Text))
						else
							Slider.Visualize.Text = Slider.Value
						end
					end
					Modifying = false
				end)
				
				UserInputService.InputChanged:connect(function(input)
					if Modifying then
						if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Space then
							Slider.Visualize:ReleaseFocus()
						end
					end
					if input.UserInputType == Enum.UserInputType.MouseMovement and Sliding then
						Slider:SetValue(MinVal + ((input.Position.X - Slider.Bar.AbsolutePosition.X) / Slider.Bar.AbsoluteSize.X) * (MaxVal - MinVal))
					end
				end)
				
				Section.YSize = Section.YSize + 42
				Section.Main.Size = UDim2.new(0,200,0,Section.YSize)
				table.insert(self.Options, Slider)
				return Slider
			end
			
			function Section:AddCP(ColorText, NewColor, Alpha, Callback)
				if Alpha then
					if typeof(Alpha) == "function" then
						Callback = Alpha
						Alpha = 1
					end
				end
				if NewColor then
					if typeof(NewColor) == "function" then
						Callback = NewColor
						NewColor = Color3.fromRGB(255,255,255)
						Alpha = 1
					end
					if typeof(NewColor) == "number" then
						Callback = Alpha
						Alpha = NewColor
						NewColor = Color3.fromRGB(255,255,255)
					end
				end
				Alpha = Alpha or 1
				local Color = {Color = NewColor, Alpha = Alpha, Closed = true, Callback = Callback}
				Color.Callback = Callback or function() end
				local Rain
				local Hue, Sat, Val = Color3.toHSV(Color3.fromRGB(NewColor.r*255,NewColor.g*255,NewColor.b*255))
				if Hue == 0 then
					Hue = 1
				end
				
				Color.Main = Library:Create("TextButton", {
					LayoutOrder = #self.Options + 1,
					Size = UDim2.new(1,0,0,22),
					BackgroundTransparency = 1,
					BackgroundColor3 = Color3.fromRGB(220,220,220),
					Text = " "..tostring(ColorText),
					TextColor3 = Color3.fromRGB(255,255,255),
					Font = Enum.Font.SourceSans,
					TextSize = 16,
					TextXAlignment = Enum.TextXAlignment.Left,
					AutoButtonColor = false,
					Parent = self.Content,
				})
				
				Color.Visualizebg = Library:Create("ImageLabel", {
					Position = UDim2.new(1,-2,0,2),
					Size = UDim2.new(0,-18,0,18),
					BorderSizePixel = 0,
					Image = "rbxassetid://3887014957",
					ScaleType = Enum.ScaleType.Tile,
					TileSize = UDim2.new(0,9,0,9),
					Parent = Color.Main
				})
				
				Color.Visualize = Library:Create("Frame", {
					Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1 - Color.Alpha,
					BackgroundColor3 = Color.Color,
					BorderSizePixel = 0,
					Parent = Color.Visualizebg,
				})
				
				Color.Container = Library:Create("Frame", {
					Position = UDim2.new(1,4,0,0),
					Size = UDim2.new(0,200,0,0),
					BackgroundColor3 = Color3.fromRGB(40,40,40),
					BorderSizePixel = 0,
					Parent = Color.Visualize
				})
				
				Color.SubContainer = Library:Create("Frame", {
					Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Parent = Color.Container
				})
				
				Color.SatVal = Library:Create("ImageLabel", {
					ZIndex = 2,
					Position = UDim2.new(0,5,0,5),
					Size = UDim2.new(1,-30,1,-30),
					BackgroundColor3 = Color3.fromHSV(Hue,1,1),
					BorderSizePixel = 0,
					Image = "rbxassetid://4155801252",
					Parent = Color.SubContainer
				})
				
				Color.Pointer = Library:Create("Frame", {
					ZIndex = 2,
					AnchorPoint = Vector2.new(0.5,0.5),
					Position = UDim2.new(Sat,0,1-Val,0),
					Size = UDim2.new(0,4,0,4),
					BackgroundTransparency = 0.4,
					BackgroundColor3 = Color3.fromRGB(255,255,255),
					BorderColor3 = Color3.fromRGB(0,0,0),
					Parent = Color.SatVal
				})
				
				Color.Hue = Library:Create("ImageLabel", {
					ZIndex = 2,
					AnchorPoint = Vector2.new(1,0),
					Position = UDim2.new(1,-5,0,5),
					Size = UDim2.new(0,15,1,-30),
					BackgroundTransparency = 0,
					Image = "rbxassetid://4174584406",
					Parent = Color.SubContainer
				})
				
				Color.Pointer1 = Library:Create("TextLabel", {
					ZIndex = 2,
					AnchorPoint = Vector2.new(0,0.5),
					Position = UDim2.new(1,-10,1-Hue,0),
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					Text = utf8.char(9668),
					TextColor3 = Color3.fromRGB(0,0,0),
					TextStrokeTransparency = 0,
					TextStrokeColor3 = Color3.fromRGB(130,130,130),
					TextSize = 6,
					Parent = Color.Hue
				})
				
				Color.Alphabg = Library:Create("ImageLabel", {
					ZIndex = 2,
					Position = UDim2.new(0,5,1,-20),
					Size = UDim2.new(1,-30,0,15),
					BorderSizePixel = 0,
					Image = "rbxassetid://3887014957",
					ScaleType = Enum.ScaleType.Tile,
					TileSize = UDim2.new(0,10,0,10),
					Parent = Color.SubContainer
				})
				
				Color.Alphaimg = Library:Create("ImageLabel", {
					ZIndex = 2,
					Size = UDim2.new(1,0,1,0),
					BackgroundTransparency = 1,
					Image = "rbxassetid://3887017050",
					ImageColor3 = NewColor,
					Parent = Color.Alphabg
				})
				
				Color.Pointer2 = Library:Create("TextLabel", {
					ZIndex = 2,
					AnchorPoint = Vector2.new(0.5,0),
					Position = UDim2.new(1 - Color.Alpha,0,1,-10),
					Size = UDim2.new(0,16,0,16),
					BackgroundTransparency = 1,
					Text = utf8.char(9650),
					TextColor3 = Color3.fromRGB(0,0,0),
					TextStrokeTransparency = 0,
					TextStrokeColor3 = Color3.fromRGB(130,130,130),
					TextSize = 6,
					Parent = Color.Alphabg
				})

				Color.Rainbow = Library:Create("Frame", {
					ZIndex = 2,
					AnchorPoint = Vector2.new(1,1),
					Position = UDim2.new(1,-5,1,-5),
					Size = UDim2.new(0,15,0,15),
					BackgroundTransparency = 0.4,
					BackgroundColor3 = Color3.fromRGB(20,20,20),
					BorderSizePixel = 0,
					Parent = Color.SubContainer
				})

				spawn(function()
					while wait() do
						Color.Rainbow.BackgroundColor3 = ChromaColor
					end
				end)
				
				AddHighlight(Color.Main)
				
				Color.Main.InputBegan:connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Color.Closed = not Color.Closed
						if Color.Closed then
							Color.Container:TweenSize(UDim2.new(0,200,0,0), "Out", "Quad", 0.2, true, function() if Color.Closed then self.Main.ClipsDescendants = true end end)
						else
							CloseWindow(Color)
							self.Main.ClipsDescendants = false
							Color.Container:TweenSize(UDim2.new(0,200,0,200), "Out", "Quad", 0.3, true)
						end
					end
				end)
				
				local Modifying
				local Modifying1
				local Modifying2
				
				function Color:UpdateSatVal(InputPos)    
					local x = (InputPos.X - Color.SatVal.AbsolutePosition.X) / Color.SatVal.AbsoluteSize.X
					local y = (InputPos.Y - Color.SatVal.AbsolutePosition.Y) / Color.SatVal.AbsoluteSize.Y
					x = tonumber(string.format("%.2f", x))
					y = tonumber(string.format("%.2f", y))
					y = y > 1 and 1 or y < 0 and 0 or y
					x = x > 1 and 1 or x < 0 and 0 or x
					Color.Pointer.Position = UDim2.new(x,0,y,0)
					Sat = x
					Val = 1-y
					Color.Color = Color3.fromHSV(Hue, Sat, Val)
					Color.Visualize.BackgroundColor3 = Color.Color
					Color.Alphaimg.ImageColor3 = Color.Color
					Color.Callback(Color.Color, Color.Alpha)
				end
				
				function Color:UpdateHue(InputPos)
					local y = (InputPos.Y - Color.Hue.AbsolutePosition.Y) / Color.Hue.AbsoluteSize.Y
					y = tonumber(string.format("%.2f", y))
					y = y > 1 and 1 or y < 0 and 0 or y
					Hue = 1-y
					Color.Color = Color3.fromHSV(Hue, Sat, Val)
					Color.Pointer1.Position = UDim2.new(1,-10,1-Hue,0)
					Color.Visualize.BackgroundColor3 = Color.Color
					Color.SatVal.BackgroundColor3 = Color3.fromHSV(Hue,1,1)
					Color.Alphaimg.ImageColor3 = Color.Color
					Color.Callback(Color.Color, Color.Alpha)
				end
				
				function Color:SetAlpha(Alpha)
					local x = (Alpha - Color.Alphabg.AbsolutePosition.X) / Color.Alphabg.AbsoluteSize.X
					x = tonumber(string.format("%.2f", x))
					x = x > 1 and 1 or x < 0 and 0 or x
					Color.Alpha = 1 - x
					Color.Pointer2.Position = UDim2.new(1 - Color.Alpha,0,1,-10)
					Color.Visualize.BackgroundTransparency = 1 - Color.Alpha
					Color.Callback(Color.Color, Color.Alpha)
				end
				
				UserInputService.InputChanged:connect(function(input)
					if not Rain and input.UserInputType == Enum.UserInputType.MouseMovement and Modifying or Modifying1 or Modifying2 then
						local Mouse = UserInputService:GetMouseLocation() + Vector2.new(0, -36)
						if Modifying then
							Color:UpdateSatVal(Mouse)
						end
						if Modifying1 then
							Color:UpdateHue(Mouse)
						end
						if Modifying2 then
							Color:SetAlpha(Mouse.X)
						end
					end
				end)
				
				Color.SatVal.InputBegan:connect(function(input)
					if not Rain and input.UserInputType == Enum.UserInputType.MouseButton1 then
						Modifying = true
						Color:UpdateSatVal(input.Position)
						input.Changed:connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								Modifying = false
							end
						end)
					end
				end)
				
				Color.SatVal.InputChanged:connect(function(input)
					if not Rain and input.UserInputType == Enum.UserInputType.MouseMovement and Modifying then
						Color:UpdateSatVal(input.Position)
					end
				end)
				
				Color.Hue.InputBegan:connect(function(input)
					if not Rain and input.UserInputType == Enum.UserInputType.MouseButton1 then
						Modifying1 = true
						Color:UpdateHue(input.Position)
						input.Changed:connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								Modifying1 = false
							end
						end)
					end
				end)
				
				Color.Hue.InputChanged:connect(function(input)
					if not Rain and input.UserInputType == Enum.UserInputType.MouseMovement and Modifying1 then
						Color:UpdateHue(input.Position)
					end
				end)
				
				Color.Alphabg.InputBegan:connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Modifying2 = true
						Color:SetAlpha(input.Position.X)
						input.Changed:connect(function()
							if input.UserInputState == Enum.UserInputState.End then
								Modifying2 = false
							end
						end)
					end
				end)
				
				Color.Alphabg.InputChanged:connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseMovement and Modifying2 then
						Color:SetAlpha(input.Position.X)
					end
				end)

				local OldColor
				local RainbowLoop
				Color.Rainbow.InputBegan:connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Rain = not Rain
						Color.Rainbow.BackgroundTransparency = Rain and 1 or 0.4
						if Rain then
							OldColor = Color.Color
							RainbowLoop = RunService.RenderStepped:connect(function()
								Color.Color = ChromaColor
								Color.Callback(Color.Color, Color.Alpha)
							end)
						else
							RainbowLoop:Disconnect()
							Color.Color = OldColor
							Color.Callback(Color.Color, Color.Alpha)
						end
					end
				end)
				
				Section.YSize = Section.YSize + 22
				Section.Main.Size = UDim2.new(0,200,0,Section.YSize)
				table.insert(self.Options, Color)
				return Color
			end
			
			table.insert(self.Sections, Section)
			return Section
		end
		
		table.insert(self.Tabs, Tab)
		return Tab
	end
end

return Library
