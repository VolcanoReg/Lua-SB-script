local partsWithId = {}
local awaitRef = {}

local root = {
	ID = 0;
	Type = "ScreenGui";
	Properties = {
		Name = "Dex";
		ResetOnSpawn = false;
	};
	Children = {
		{
			ID = 1;
			Type = "Frame";
			Properties = {
				Position = UDim2.new(1,0,0.5,36);
				BackgroundTransparency = 0.10000000149011612;
				Name = "PropertiesFrame";
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Size = UDim2.new(0,300,0.5,-36);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 2;
					Type = "LocalScript";
					Properties = {
						Name = "Properties";
					};
					Children = {
						{
							ID = 3;
							Type = "ModuleScript";
							Properties = {
								Name = "RawApiJson";
							};
							Children = {};
						};
					};
				};
				{
					ID = 4;
					Type = "Frame";
					Properties = {
						Name = "Header";
						Position = UDim2.new(0,0,0,-36);
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,36);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 5;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Properties";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								Size = UDim2.new(1,-4,0.5,0);
							};
							Children = {};
						};
						{
							ID = 6;
							Type = "TextBox";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Search Properties";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.800000011920929;
								Position = UDim2.new(0,4,0.5,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								Size = UDim2.new(1,-8,0.5,-3);
							};
							Children = {};
						};
					};
				};
				{
					ID = 7;
					Type = "BindableFunction";
					Properties = {
						Name = "GetApi";
					};
					Children = {};
				};
				{
					ID = 8;
					Type = "BindableFunction";
					Properties = {
						Name = "GetAwaiting";
					};
					Children = {};
				};
				{
					ID = 9;
					Type = "BindableEvent";
					Properties = {
						Name = "SetAwaiting";
					};
					Children = {};
				};
			};
		};
		{
			ID = 10;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 0.10000000149011612;
				Name = "ExplorerPanel";
				Position = UDim2.new(1,0,0,0);
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Size = UDim2.new(0,300,0.5,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 11;
					Type = "BindableEvent";
					Properties = {
						Name = "SelectionChanged";
					};
					Children = {};
				};
				{
					ID = 12;
					Type = "BindableFunction";
					Properties = {
						Name = "SetOption";
					};
					Children = {};
				};
				{
					ID = 13;
					Type = "BindableFunction";
					Properties = {
						Name = "SetSelection";
					};
					Children = {};
				};
				{
					ID = 14;
					Type = "BindableFunction";
					Properties = {
						Name = "GetOption";
					};
					Children = {};
				};
				{
					ID = 15;
					Type = "BindableFunction";
					Properties = {
						Name = "GetSelection";
					};
					Children = {};
				};
				{
					ID = 16;
					Type = "LocalScript";
					Properties = {};
					Children = {};
				};
				{
					ID = 17;
					Type = "BindableFunction";
					Properties = {
						Name = "GetPrint";
					};
					Children = {};
				};
			};
		};
		{
			ID = 18;
			Type = "LocalScript";
			Properties = {
				Name = "Selection";
			};
			Children = {};
		};
		{
			ID = 19;
			Type = "Frame";
			Properties = {
				Visible = false;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				BackgroundTransparency = 1;
				Name = "SideMenu";
				Position = UDim2.new(1,-330,0,0);
				Size = UDim2.new(0,30,0,180);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 20;
					Type = "TextButton";
					Properties = {
						FontSize = Enum.FontSize.Size24;
						Active = false;
						TextTransparency = 1;
						Text = ">";
						TextSize = 24;
						AutoButtonColor = false;
						Size = UDim2.new(0,30,0,30);
						Font = Enum.Font.SourceSans;
						Name = "Toggle";
						Position = UDim2.new(0,0,0,60);
						TextWrapped = true;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
						BorderSizePixel = 0;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 21;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						Text = "DEX";
						BackgroundTransparency = 1;
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Title";
						Size = UDim2.new(0,30,0,20);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 14;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 22;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size12;
						Text = "v3";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,30,0,20);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Version";
						Position = UDim2.new(0,0,0,15);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 12;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 23;
					Type = "ImageLabel";
					Properties = {
						ImageColor3 = Color3.new(233/255,233/255,233/255);
						Image = "rbxassetid://1513966937";
						Name = "Slant";
						Position = UDim2.new(0,0,0,90);
						BackgroundTransparency = 1;
						Rotation = 180;
						Size = UDim2.new(0,30,0,30);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 24;
					Type = "Frame";
					Properties = {
						Size = UDim2.new(0,30,0,30);
						Name = "Main";
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {};
				};
				{
					ID = 25;
					Type = "Frame";
					Properties = {
						Position = UDim2.new(0,0,0,30);
						Name = "SlideOut";
						ClipsDescendants = true;
						BackgroundTransparency = 1;
						Size = UDim2.new(0,30,0,150);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(44/51,44/51,44/51);
					};
					Children = {
						{
							ID = 26;
							Type = "Frame";
							Properties = {
								Name = "SlideFrame";
								Position = UDim2.new(0,0,0,-120);
								Size = UDim2.new(0,30,0,120);
								BorderSizePixel = 0;
								BackgroundColor3 = Color3.new(44/51,44/51,44/51);
							};
							Children = {
								{
									ID = 27;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size24;
										Text = "";
										AutoButtonColor = false;
										Size = UDim2.new(0,30,0,30);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Position = UDim2.new(0,0,0,90);
										TextSize = 24;
										Name = "Explorer";
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {
										{
											ID = 28;
											Type = "ImageLabel";
											Properties = {
												ImageColor3 = Color3.new(14/51,14/51,14/51);
												Image = "rbxassetid://472635937";
												Name = "Icon";
												Position = UDim2.new(0,5,0,5);
												BackgroundTransparency = 1;
												ZIndex = 2;
												Size = UDim2.new(0,20,0,20);
												BackgroundColor3 = Color3.new(1,1,1);
											};
											Children = {};
										};
									};
								};
								{
									ID = 29;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size24;
										Text = "";
										AutoButtonColor = false;
										Size = UDim2.new(0,30,0,30);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Position = UDim2.new(0,0,0,60);
										TextSize = 24;
										Name = "SaveMap";
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {
										{
											ID = 30;
											Type = "ImageLabel";
											Properties = {
												ImageColor3 = Color3.new(14/51,14/51,14/51);
												Image = "rbxassetid://472636337";
												Name = "Icon";
												Position = UDim2.new(0,5,0,5);
												BackgroundTransparency = 1;
												ZIndex = 2;
												Size = UDim2.new(0,20,0,20);
												BackgroundColor3 = Color3.new(1,1,1);
											};
											Children = {};
										};
									};
								};
								{
									ID = 31;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size24;
										Text = "";
										AutoButtonColor = false;
										Size = UDim2.new(0,30,0,30);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Position = UDim2.new(0,0,0,30);
										TextSize = 24;
										Name = "Settings";
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {
										{
											ID = 32;
											Type = "ImageLabel";
											Properties = {
												ImageColor3 = Color3.new(14/51,14/51,14/51);
												Image = "rbxassetid://472635774";
												Name = "Icon";
												Position = UDim2.new(0,5,0,5);
												BackgroundTransparency = 1;
												ZIndex = 2;
												Size = UDim2.new(0,20,0,20);
												BackgroundColor3 = Color3.new(1,1,1);
											};
											Children = {};
										};
									};
								};
								{
									ID = 33;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size24;
										Text = "";
										AutoButtonColor = false;
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Size = UDim2.new(0,30,0,30);
										Name = "About";
										TextSize = 24;
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {
										{
											ID = 34;
											Type = "ImageLabel";
											Properties = {
												ImageColor3 = Color3.new(14/51,14/51,14/51);
												Image = "rbxassetid://476354004";
												Name = "Icon";
												Position = UDim2.new(0,5,0,5);
												BackgroundTransparency = 1;
												ZIndex = 2;
												Size = UDim2.new(0,20,0,20);
												BackgroundColor3 = Color3.new(1,1,1);
											};
											Children = {};
										};
									};
								};
							};
						};
					};
				};
				{
					ID = 35;
					Type = "TextButton";
					Properties = {
						FontSize = Enum.FontSize.Size24;
						Active = false;
						Text = "";
						AutoButtonColor = false;
						Font = Enum.Font.SourceSans;
						Name = "OpenScriptEditor";
						Position = UDim2.new(0,0,0,30);
						Size = UDim2.new(0,30,0,30);
						TextSize = 24;
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 36;
							Type = "ImageLabel";
							Properties = {
								ImageColor3 = Color3.new(9/85,14/85,53/255);
								ImageTransparency = 1;
								BackgroundTransparency = 1;
								Image = "rbxassetid://475456048";
								Name = "Icon";
								Position = UDim2.new(0,5,0,5);
								Size = UDim2.new(0,20,0,20);
								ZIndex = 2;
								BorderSizePixel = 0;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 37;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 0.10000000149011612;
				Name = "SettingsPanel";
				Position = UDim2.new(1,0,0,0);
				BorderColor3 = Color3.new(191/255,191/255,191/255);
				Size = UDim2.new(0,300,1,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 38;
					Type = "Frame";
					Properties = {
						Name = "Header";
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,17);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 39;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Settings";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								BorderSizePixel = 0;
								Size = UDim2.new(1,-4,1,0);
							};
							Children = {};
						};
					};
				};
				{
					ID = 40;
					Type = "BindableFunction";
					Properties = {
						Name = "GetSetting";
					};
					Children = {};
				};
				{
					ID = 41;
					Type = "Frame";
					Properties = {
						Visible = false;
						Name = "SettingTemplate";
						Position = UDim2.new(0,0,0,18);
						BackgroundTransparency = 1;
						Size = UDim2.new(1,0,0,60);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 42;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								Text = "SettingName";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "SName";
								Position = UDim2.new(0,10,0,0);
								BackgroundTransparency = 1;
								Size = UDim2.new(1,-20,0,30);
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 43;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								Text = "Off";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "Status";
								Position = UDim2.new(0,60,0,30);
								BackgroundTransparency = 1;
								Size = UDim2.new(0,50,0,15);
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 44;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "";
								Font = Enum.Font.SourceSans;
								Name = "Change";
								Position = UDim2.new(0,10,0,30);
								TextSize = 14;
								Size = UDim2.new(0,40,0,15);
								BorderSizePixel = 0;
								BackgroundColor3 = Color3.new(44/51,44/51,44/51);
							};
							Children = {
								{
									ID = 45;
									Type = "TextLabel";
									Properties = {
										Font = Enum.Font.SourceSans;
										FontSize = Enum.FontSize.Size14;
										Name = "OnBar";
										TextSize = 14;
										Size = UDim2.new(0,0,0,15);
										Text = "";
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(0,49/85,44/51);
									};
									Children = {};
								};
								{
									ID = 46;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										ClipsDescendants = true;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Bar";
										Position = UDim2.new(0,-2,0,-2);
										Size = UDim2.new(0,10,0,19);
										TextSize = 14;
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(0,0,0);
									};
									Children = {};
								};
							};
						};
					};
				};
				{
					ID = 47;
					Type = "Frame";
					Properties = {
						Name = "SettingList";
						Position = UDim2.new(0,0,0,17);
						BackgroundTransparency = 1;
						Size = UDim2.new(1,0,1,-17);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
			};
		};
		{
			ID = 48;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "SaveInstance";
				Position = UDim2.new(0.30000001192092896,0,0.30000001192092896,0);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 49;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Save Instance";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 2;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 50;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						BackgroundTransparency = 0.10000000149011612;
						Size = UDim2.new(1,0,0,200);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 51;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Save";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.07500000298023224,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Save";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 52;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "This will save an instance to your PC. Type in the name for your instance. (.rbxmx will be added automatically.)";
								BackgroundTransparency = 1;
								TextWrapped = true;
								Font = Enum.Font.SourceSans;
								Name = "Desc";
								Position = UDim2.new(0,0,0,20);
								Size = UDim2.new(1,0,0,40);
								BackgroundColor3 = Color3.new(1,1,1);
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
						{
							ID = 53;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Cancel";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.5249999761581421,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Cancel";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 54;
							Type = "TextBox";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								Text = "";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "FileName";
								Position = UDim2.new(0.07500000298023224,0,0.4000000059604645,0);
								BackgroundTransparency = 0.20000000298023224;
								Size = UDim2.new(0.8500000238418579,0,0,30);
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 55;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								TextColor3 = Color3.new(1,1,1);
								Text = "";
								Size = UDim2.new(0,20,0,20);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.6000000238418579;
								Position = UDim2.new(0.07500000298023224,0,0.625,0);
								Name = "SaveObjects";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 56;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										BackgroundTransparency = 0.4000000059604645;
										Font = Enum.Font.SourceSans;
										Name = "enabled";
										Position = UDim2.new(0,3,0,3);
										TextSize = 14;
										Size = UDim2.new(0,14,0,14);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(97/255,97/255,97/255);
									};
									Children = {};
								};
							};
						};
						{
							ID = 57;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "Save \"Object\" type values";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "Desc2";
								Position = UDim2.new(0.07500000298023224,30,0.625,0);
								BackgroundTransparency = 1;
								Size = UDim2.new(0.925000011920929,-30,0,20);
								TextSize = 14;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 58;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "Confirmation";
				Position = UDim2.new(0.5,-175,0.5,-75);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 3;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 59;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Confirm";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 3;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 60;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BackgroundTransparency = 0.10000000149011612;
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						ZIndex = 2;
						Size = UDim2.new(1,0,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 61;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Yes";
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.07500000298023224,0,1,-40);
								Name = "Yes";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 62;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "The file, FILENAME, already exists. Overwrite?";
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,40);
								TextWrapped = true;
								Font = Enum.Font.SourceSans;
								Name = "Desc";
								Position = UDim2.new(0,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
								ZIndex = 2;
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
						{
							ID = 63;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "No";
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.5249999761581421,0,1,-40);
								Name = "No";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 64;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "Caution";
				Position = UDim2.new(0.5,-175,0.5,-75);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 5;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 65;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Caution";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 5;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 66;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BackgroundTransparency = 0.10000000149011612;
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						ZIndex = 4;
						Size = UDim2.new(1,0,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 67;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "The file, FILENAME, already exists. Overwrite?";
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,42);
								TextWrapped = true;
								Font = Enum.Font.SourceSans;
								Name = "Desc";
								Position = UDim2.new(0,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
								ZIndex = 4;
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
						{
							ID = 68;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Ok";
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.30000001192092896,0,1,-40);
								Name = "Ok";
								ZIndex = 4;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 69;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "CallRemote";
				Position = UDim2.new(0.5,-175,0.5,-100);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 70;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Call Remote";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 2;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 71;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						BackgroundTransparency = 0.10000000149011612;
						Size = UDim2.new(1,0,0,200);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 72;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "Arguments";
								BackgroundTransparency = 1;
								TextWrapped = true;
								Font = Enum.Font.SourceSans;
								Name = "Desc";
								Position = UDim2.new(0,0,0,20);
								Size = UDim2.new(1,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
						{
							ID = 73;
							Type = "ScrollingFrame";
							Properties = {
								MidImage = "rbxasset://textures/blackBkg_square.png";
								Size = UDim2.new(1,0,0,80);
								BackgroundTransparency = 1;
								Position = UDim2.new(0,0,0,40);
								Name = "Arguments";
								ScrollingDirection = Enum.ScrollingDirection.Y;
								TopImage = "rbxasset://textures/blackBkg_square.png";
								BottomImage = "rbxasset://textures/blackBkg_square.png";
								BackgroundColor3 = Color3.new(1,1,1);
								CanvasSize = UDim2.new();
							};
							Children = {};
						};
						{
							ID = 74;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								TextColor3 = Color3.new(1,1,1);
								Text = "";
								Size = UDim2.new(0,20,0,20);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.6000000238418579;
								Position = UDim2.new(0.07500000298023224,0,0.625,0);
								Name = "DisplayReturned";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 75;
									Type = "TextLabel";
									Properties = {
										Visible = false;
										FontSize = Enum.FontSize.Size14;
										Text = "";
										BackgroundTransparency = 0.4000000059604645;
										Font = Enum.Font.SourceSans;
										Name = "enabled";
										Position = UDim2.new(0,3,0,3);
										Size = UDim2.new(0,14,0,14);
										TextSize = 14;
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(97/255,97/255,97/255);
									};
									Children = {};
								};
							};
						};
						{
							ID = 76;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								Text = "Display values returned";
								TextXAlignment = Enum.TextXAlignment.Left;
								Font = Enum.Font.SourceSans;
								Name = "Desc2";
								Position = UDim2.new(0.07500000298023224,30,0.625,0);
								BackgroundTransparency = 1;
								Size = UDim2.new(0.925000011920929,-30,0,20);
								TextSize = 14;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 77;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size24;
								BorderColor3 = Color3.new(0,0,0);
								Text = "+";
								Font = Enum.Font.SourceSansBold;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.800000011920929,0,0.625,0);
								Size = UDim2.new(0,20,0,20);
								Name = "Add";
								TextSize = 24;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 78;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size24;
								BorderColor3 = Color3.new(0,0,0);
								Text = "-";
								Font = Enum.Font.SourceSansBold;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.8999999761581421,0,0.625,0);
								Size = UDim2.new(0,20,0,20);
								Name = "Subtract";
								TextSize = 24;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 79;
							Type = "Frame";
							Properties = {
								Visible = false;
								Name = "ArgumentTemplate";
								BorderColor3 = Color3.new(191/255,191/255,191/255);
								BackgroundTransparency = 0.5;
								Size = UDim2.new(1,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 80;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										BorderColor3 = Color3.new(0,0,0);
										Text = "Script";
										Font = Enum.Font.SourceSans;
										Name = "Type";
										BackgroundTransparency = 0.8999999761581421;
										Size = UDim2.new(0.4000000059604645,0,0,20);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 81;
									Type = "TextBox";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Value";
										Position = UDim2.new(0.4000000059604645,0,0,0);
										BackgroundTransparency = 0.8999999761581421;
										Size = UDim2.new(0.6000000238418579,-12,0,20);
										TextSize = 14;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
							};
						};
						{
							ID = 82;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Cancel";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.5249999761581421,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Cancel";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 83;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Call";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.07500000298023224,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Ok";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 84;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Draggable = true;
				Name = "TableCaution";
				Position = UDim2.new(0.30000001192092896,0,0.30000001192092896,0);
				Size = UDim2.new(0,350,0,20);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 85;
					Type = "Frame";
					Properties = {
						Name = "MainWindow";
						BorderColor3 = Color3.new(191/255,191/255,191/255);
						BackgroundTransparency = 0.10000000149011612;
						Size = UDim2.new(1,0,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 86;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								BorderColor3 = Color3.new(0,0,0);
								Text = "Ok";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0.30000001192092896,0,1,-40);
								Size = UDim2.new(0.4000000059604645,0,0,30);
								Name = "Ok";
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 87;
							Type = "ScrollingFrame";
							Properties = {
								MidImage = "rbxasset://textures/blackBkg_square.png";
								Size = UDim2.new(1,0,0,80);
								BackgroundTransparency = 1;
								Position = UDim2.new(0,0,0,20);
								Name = "TableResults";
								ScrollingDirection = Enum.ScrollingDirection.Y;
								TopImage = "rbxasset://textures/blackBkg_square.png";
								BottomImage = "rbxasset://textures/blackBkg_square.png";
								BackgroundColor3 = Color3.new(1,1,1);
								CanvasSize = UDim2.new();
							};
							Children = {};
						};
						{
							ID = 88;
							Type = "Frame";
							Properties = {
								Visible = false;
								Name = "TableTemplate";
								BorderColor3 = Color3.new(191/255,191/255,191/255);
								BackgroundTransparency = 0.5;
								Size = UDim2.new(1,0,0,20);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 89;
									Type = "TextLabel";
									Properties = {
										BackgroundTransparency = 0.8999999761581421;
										FontSize = Enum.FontSize.Size18;
										Name = "Type";
										Font = Enum.Font.SourceSans;
										Size = UDim2.new(0.4000000059604645,0,0,20);
										Text = "Script";
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 90;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "Script";
										Font = Enum.Font.SourceSans;
										Name = "Value";
										Position = UDim2.new(0.4000000059604645,0,0,0);
										BackgroundTransparency = 0.8999999761581421;
										Size = UDim2.new(0.6000000238418579,-12,0,20);
										TextSize = 14;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
							};
						};
					};
				};
				{
					ID = 91;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Caution";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 2;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
			};
		};
		{
			ID = 92;
			Type = "Frame";
			Properties = {
				Visible = false;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Name = "ScriptEditor";
				Position = UDim2.new(0.5,-258,0.5,-208);
				Draggable = true;
				ZIndex = 5;
				Size = UDim2.new(0,516,0,20);
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 93;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						TextColor3 = Color3.new(0,0,0);
						Text = "Script Viewer";
						Font = Enum.Font.SourceSans;
						Name = "Title";
						TextXAlignment = Enum.TextXAlignment.Left;
						BackgroundTransparency = 1;
						ZIndex = 5;
						TextSize = 14;
						Size = UDim2.new(1,0,1,0);
					};
					Children = {};
				};
				{
					ID = 94;
					Type = "Frame";
					Properties = {
						Name = "Cover";
						Position = UDim2.new(0,0,3,0);
						Size = UDim2.new(0,516,0,416);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 95;
					Type = "Frame";
					Properties = {
						Name = "EditorGrid";
						Position = UDim2.new(0,0,3,0);
						Size = UDim2.new(0,500,0,400);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 96;
					Type = "Frame";
					Properties = {
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,3,0);
						Name = "TopBar";
						BackgroundColor3 = Color3.new(16/17,16/17,16/17);
					};
					Children = {
						{
							ID = 97;
							Type = "ImageButton";
							Properties = {
								Position = UDim2.new(1,-32,0,40);
								Name = "ScriptBarLeft";
								Active = false;
								BorderColor3 = Color3.new(149/255,149/255,149/255);
								Size = UDim2.new(0,16,0,20);
								BackgroundColor3 = Color3.new(13/15,13/15,13/15);
								AutoButtonColor = false;
							};
							Children = {
								{
									ID = 98;
									Type = "Frame";
									Properties = {
										Name = "Arrow Graphic";
										Position = UDim2.new(0.5,-4,0.5,-4);
										BackgroundTransparency = 1;
										BorderSizePixel = 0;
										Size = UDim2.new(0,8,0,8);
									};
									Children = {
										{
											ID = 99;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.25,0,0.375,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.25,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 100;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.375,0,0.25,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.5,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 101;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.5,0,0.125,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.75,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 102;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.625,0,0,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,1,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 103;
							Type = "ImageButton";
							Properties = {
								Position = UDim2.new(1,-16,0,40);
								Name = "ScriptBarRight";
								Active = false;
								BorderColor3 = Color3.new(149/255,149/255,149/255);
								Size = UDim2.new(0,16,0,20);
								BackgroundColor3 = Color3.new(13/15,13/15,13/15);
								AutoButtonColor = false;
							};
							Children = {
								{
									ID = 104;
									Type = "Frame";
									Properties = {
										Name = "Arrow Graphic";
										Position = UDim2.new(0.5,-4,0.5,-4);
										BackgroundTransparency = 1;
										BorderSizePixel = 0;
										Size = UDim2.new(0,8,0,8);
									};
									Children = {
										{
											ID = 105;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.625,0,0.375,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.25,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 106;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.5,0,0.25,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.5,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 107;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.375,0,0.125,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,0.75,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
										{
											ID = 108;
											Type = "Frame";
											Properties = {
												Name = "Graphic";
												Position = UDim2.new(0.25,0,0,0);
												BackgroundTransparency = 0.699999988079071;
												Size = UDim2.new(0.125,0,1,0);
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(149/255,149/255,149/255);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 109;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								BorderColor3 = Color3.new(0,0,0);
								Text = "To Clipboard";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.5;
								Position = UDim2.new(0,0,0,20);
								Size = UDim2.new(0,80,0,20);
								Name = "Clipboard";
								TextSize = 14;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {};
						};
						{
							ID = 110;
							Type = "Frame";
							Properties = {
								Name = "ScriptBar";
								ClipsDescendants = true;
								BorderColor3 = Color3.new(149/255,149/255,149/255);
								Position = UDim2.new(0,0,0,40);
								Size = UDim2.new(1,-32,0,20);
								BackgroundColor3 = Color3.new(14/17,14/17,14/17);
							};
							Children = {};
						};
						{
							ID = 111;
							Type = "Frame";
							Properties = {
								Visible = false;
								Name = "Entry";
								BackgroundTransparency = 1;
								Size = UDim2.new(0,100,1,0);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 112;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size12;
										ClipsDescendants = true;
										BorderColor3 = Color3.new(0,0,0);
										Text = "";
										Size = UDim2.new(1,0,1,0);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 0.6000000238418579;
										TextXAlignment = Enum.TextXAlignment.Left;
										Name = "Button";
										ZIndex = 4;
										TextSize = 12;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 113;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										BorderColor3 = Color3.new(0,0,0);
										Text = "X";
										Size = UDim2.new(0,20,0,20);
										Font = Enum.Font.SourceSans;
										BackgroundTransparency = 1;
										Position = UDim2.new(1,-20,0,0);
										Name = "Close";
										ZIndex = 4;
										TextSize = 14;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
							};
						};
					};
				};
				{
					ID = 114;
					Type = "BindableEvent";
					Properties = {
						Name = "OpenScript";
					};
					Children = {};
				};
				{
					ID = 115;
					Type = "LocalScript";
					Properties = {};
					Children = {};
				};
				{
					ID = 116;
					Type = "TextButton";
					Properties = {
						FontSize = Enum.FontSize.Size14;
						BorderColor3 = Color3.new(0,0,0);
						Text = "X";
						Size = UDim2.new(0,20,0,20);
						Font = Enum.Font.SourceSans;
						BackgroundTransparency = 1;
						Position = UDim2.new(1,-20,0,0);
						Name = "Close";
						ZIndex = 5;
						TextSize = 14;
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
			};
		};
		{
			ID = 117;
			Type = "Frame";
			Properties = {
				Name = "IntroFrame";
				Position = UDim2.new(1,30,0,0);
				Size = UDim2.new(0,301,1,0);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(49/51,49/51,49/51);
			};
			Children = {
				{
					ID = 118;
					Type = "Frame";
					Properties = {
						Name = "Main";
						Position = UDim2.new(0,-30,0,0);
						Size = UDim2.new(0,30,0,90);
						ZIndex = 2;
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(49/51,49/51,49/51);
					};
					Children = {};
				};
				{
					ID = 119;
					Type = "ImageLabel";
					Properties = {
						ImageColor3 = Color3.new(49/51,49/51,49/51);
						Rotation = 180;
						Image = "rbxassetid://1513966937";
						BackgroundTransparency = 1;
						Position = UDim2.new(0,-30,0,90);
						Name = "Slant";
						ZIndex = 2;
						Size = UDim2.new(0,30,0,30);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 120;
					Type = "Frame";
					Properties = {
						Name = "Main";
						Position = UDim2.new(0,-30,0,0);
						Size = UDim2.new(0,30,0,90);
						ZIndex = 2;
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(49/51,49/51,49/51);
					};
					Children = {};
				};
				{
					ID = 121;
					Type = "ImageLabel";
					Properties = {
						ImageColor3 = Color3.new(49/51,49/51,49/51);
						Image = "rbxassetid://483437370";
						Name = "Sad";
						Position = UDim2.new(0,50,1,-250);
						BackgroundTransparency = 1;
						ZIndex = 2;
						Size = UDim2.new(0,200,0,200);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 122;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size28;
						Text = "By Moon";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,140,0,30);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Creator";
						Position = UDim2.new(0,80,0,300);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 28;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 123;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size60;
						Text = "DEX";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,100,0,60);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Title";
						Position = UDim2.new(0,100,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 60;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 124;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size28;
						Text = "v3";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,100,0,30);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Version";
						Position = UDim2.new(0,100,0,210);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 28;
						TextWrap = true;
					};
					Children = {};
				};
			};
		};
		{
			ID = 125;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 0.10000000149011612;
				Name = "SaveMapWindow";
				Position = UDim2.new(1,0,0,0);
				BorderColor3 = Color3.new(191/255,191/255,191/255);
				Size = UDim2.new(0,300,1,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 126;
					Type = "Frame";
					Properties = {
						Name = "Header";
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,17);
						BorderSizePixel = 0;
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 127;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Map Downloader";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								BorderSizePixel = 0;
								Size = UDim2.new(1,-4,1,0);
							};
							Children = {};
						};
					};
				};
				{
					ID = 128;
					Type = "Frame";
					Properties = {
						Name = "MapSettings";
						Position = UDim2.new(0,0,0,200);
						BackgroundTransparency = 1;
						Size = UDim2.new(1,0,0,240);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 129;
							Type = "Frame";
							Properties = {
								Name = "Terrain";
								Position = UDim2.new(0,0,0,60);
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,60);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 130;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Save Terrain";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "SName";
										Position = UDim2.new(0,10,0,0);
										BackgroundTransparency = 1;
										Size = UDim2.new(1,-20,0,30);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 131;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Off";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Status";
										Position = UDim2.new(0,60,0,30);
										BackgroundTransparency = 1;
										Size = UDim2.new(0,50,0,15);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 132;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Change";
										Position = UDim2.new(0,10,0,30);
										TextSize = 14;
										Size = UDim2.new(0,40,0,15);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(44/51,44/51,44/51);
									};
									Children = {
										{
											ID = 133;
											Type = "TextLabel";
											Properties = {
												Font = Enum.Font.SourceSans;
												FontSize = Enum.FontSize.Size14;
												Name = "OnBar";
												TextSize = 14;
												Size = UDim2.new(0,0,0,15);
												Text = "";
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,49/85,44/51);
											};
											Children = {};
										};
										{
											ID = 134;
											Type = "TextLabel";
											Properties = {
												FontSize = Enum.FontSize.Size14;
												ClipsDescendants = true;
												Text = "";
												Font = Enum.Font.SourceSans;
												Name = "Bar";
												Position = UDim2.new(0,-2,0,-2);
												Size = UDim2.new(0,10,0,19);
												TextSize = 14;
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,0,0);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 135;
							Type = "Frame";
							Properties = {
								Name = "Lighting";
								Position = UDim2.new(0,0,0,120);
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,60);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 136;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Lighting Properties";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "SName";
										Position = UDim2.new(0,10,0,0);
										BackgroundTransparency = 1;
										Size = UDim2.new(1,-20,0,30);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 137;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Off";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Status";
										Position = UDim2.new(0,60,0,30);
										BackgroundTransparency = 1;
										Size = UDim2.new(0,50,0,15);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 138;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Change";
										Position = UDim2.new(0,10,0,30);
										TextSize = 14;
										Size = UDim2.new(0,40,0,15);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(44/51,44/51,44/51);
									};
									Children = {
										{
											ID = 139;
											Type = "TextLabel";
											Properties = {
												Font = Enum.Font.SourceSans;
												FontSize = Enum.FontSize.Size14;
												Name = "OnBar";
												TextSize = 14;
												Size = UDim2.new(0,0,0,15);
												Text = "";
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,49/85,44/51);
											};
											Children = {};
										};
										{
											ID = 140;
											Type = "TextLabel";
											Properties = {
												FontSize = Enum.FontSize.Size14;
												ClipsDescendants = true;
												Text = "";
												Font = Enum.Font.SourceSans;
												Name = "Bar";
												Position = UDim2.new(0,-2,0,-2);
												Size = UDim2.new(0,10,0,19);
												TextSize = 14;
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,0,0);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 141;
							Type = "Frame";
							Properties = {
								Name = "CameraInstances";
								Position = UDim2.new(0,0,0,180);
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,60);
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 142;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Camera Instances";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "SName";
										Position = UDim2.new(0,10,0,0);
										BackgroundTransparency = 1;
										Size = UDim2.new(1,-20,0,30);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 143;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Off";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Status";
										Position = UDim2.new(0,60,0,30);
										BackgroundTransparency = 1;
										Size = UDim2.new(0,50,0,15);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 144;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Change";
										Position = UDim2.new(0,10,0,30);
										TextSize = 14;
										Size = UDim2.new(0,40,0,15);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(44/51,44/51,44/51);
									};
									Children = {
										{
											ID = 145;
											Type = "TextLabel";
											Properties = {
												Font = Enum.Font.SourceSans;
												FontSize = Enum.FontSize.Size14;
												Name = "OnBar";
												TextSize = 14;
												Size = UDim2.new(0,0,0,15);
												Text = "";
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,49/85,44/51);
											};
											Children = {};
										};
										{
											ID = 146;
											Type = "TextLabel";
											Properties = {
												FontSize = Enum.FontSize.Size14;
												ClipsDescendants = true;
												Text = "";
												Font = Enum.Font.SourceSans;
												Name = "Bar";
												Position = UDim2.new(0,-2,0,-2);
												Size = UDim2.new(0,10,0,19);
												TextSize = 14;
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,0,0);
											};
											Children = {};
										};
									};
								};
							};
						};
						{
							ID = 147;
							Type = "Frame";
							Properties = {
								BackgroundTransparency = 1;
								Size = UDim2.new(1,0,0,60);
								Name = "Scripts";
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 148;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Save Scripts";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "SName";
										Position = UDim2.new(0,10,0,0);
										BackgroundTransparency = 1;
										Size = UDim2.new(1,-20,0,30);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 149;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size18;
										Text = "Off";
										TextXAlignment = Enum.TextXAlignment.Left;
										Font = Enum.Font.SourceSans;
										Name = "Status";
										Position = UDim2.new(0,60,0,30);
										BackgroundTransparency = 1;
										Size = UDim2.new(0,50,0,15);
										TextSize = 18;
										BackgroundColor3 = Color3.new(1,1,1);
									};
									Children = {};
								};
								{
									ID = 150;
									Type = "TextButton";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										Font = Enum.Font.SourceSans;
										Name = "Change";
										Position = UDim2.new(0,10,0,30);
										TextSize = 14;
										Size = UDim2.new(0,40,0,15);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(44/51,44/51,44/51);
									};
									Children = {
										{
											ID = 151;
											Type = "TextLabel";
											Properties = {
												Font = Enum.Font.SourceSans;
												FontSize = Enum.FontSize.Size14;
												Name = "OnBar";
												TextSize = 14;
												Size = UDim2.new(0,0,0,15);
												Text = "";
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,49/85,44/51);
											};
											Children = {};
										};
										{
											ID = 152;
											Type = "TextLabel";
											Properties = {
												FontSize = Enum.FontSize.Size14;
												ClipsDescendants = true;
												Text = "";
												Font = Enum.Font.SourceSans;
												Name = "Bar";
												Position = UDim2.new(0,-2,0,-2);
												Size = UDim2.new(0,10,0,19);
												TextSize = 14;
												BorderSizePixel = 0;
												BackgroundColor3 = Color3.new(0,0,0);
											};
											Children = {};
										};
									};
								};
							};
						};
					};
				};
				{
					ID = 153;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size18;
						TextColor3 = Color3.new(0,0,0);
						Text = "To Save";
						Font = Enum.Font.SourceSans;
						Name = "ToSave";
						Position = UDim2.new(0,0,0,17);
						BackgroundTransparency = 1;
						TextSize = 18;
						Size = UDim2.new(1,0,0,20);
					};
					Children = {};
				};
				{
					ID = 154;
					Type = "Frame";
					Properties = {
						Name = "CopyList";
						Position = UDim2.new(0,0,0,37);
						BackgroundTransparency = 0.800000011920929;
						Size = UDim2.new(1,0,0,163);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 155;
					Type = "Frame";
					Properties = {
						Name = "Bottom";
						Position = UDim2.new(0,0,1,-50);
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,50);
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 156;
							Type = "TextLabel";
							Properties = {
								TextWrapped = true;
								TextColor3 = Color3.new(0,0,0);
								Text = "After the map saves, open a new place on studio, then right click Lighting and \"Insert from file...\", then select your file and run the unpacker script inside the folder.";
								TextXAlignment = Enum.TextXAlignment.Left;
								FontSize = Enum.FontSize.Size14;
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								Size = UDim2.new(1,-4,1,0);
								TextYAlignment = Enum.TextYAlignment.Top;
								TextSize = 14;
								TextWrap = true;
							};
							Children = {};
						};
					};
				};
				{
					ID = 157;
					Type = "TextButton";
					Properties = {
						FontSize = Enum.FontSize.Size18;
						BorderColor3 = Color3.new(0,0,0);
						Text = "Save";
						Font = Enum.Font.SourceSans;
						BackgroundTransparency = 0.800000011920929;
						Position = UDim2.new(0,0,1,-80);
						Size = UDim2.new(1,0,0,30);
						Name = "Save";
						TextSize = 18;
						BackgroundColor3 = Color3.new(16/17,16/17,16/17);
					};
					Children = {};
				};
				{
					ID = 158;
					Type = "TextBox";
					Properties = {
						FontSize = Enum.FontSize.Size18;
						Text = "PlaceName";
						TextXAlignment = Enum.TextXAlignment.Left;
						Font = Enum.Font.SourceSans;
						Name = "FileName";
						Position = UDim2.new(0,0,1,-105);
						BackgroundTransparency = 0.6000000238418579;
						Size = UDim2.new(1,0,0,25);
						TextSize = 18;
						BackgroundColor3 = Color3.new(16/17,16/17,16/17);
					};
					Children = {};
				};
				{
					ID = 159;
					Type = "Frame";
					Properties = {
						Visible = false;
						Name = "Entry";
						BackgroundTransparency = 1;
						Size = UDim2.new(1,0,0,22);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {
						{
							ID = 160;
							Type = "TextButton";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								TextColor3 = Color3.new(1,1,1);
								Text = "";
								Size = UDim2.new(0,20,0,20);
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 0.6000000238418579;
								Position = UDim2.new(0,10,0,1);
								Name = "Change";
								ZIndex = 2;
								TextSize = 18;
								BackgroundColor3 = Color3.new(1,1,1);
							};
							Children = {
								{
									ID = 161;
									Type = "TextLabel";
									Properties = {
										FontSize = Enum.FontSize.Size14;
										Text = "";
										BackgroundTransparency = 0.4000000059604645;
										Font = Enum.Font.SourceSans;
										Name = "enabled";
										Position = UDim2.new(0,3,0,3);
										TextSize = 14;
										Size = UDim2.new(0,14,0,14);
										BorderSizePixel = 0;
										BackgroundColor3 = Color3.new(97/255,97/255,97/255);
									};
									Children = {};
								};
							};
						};
						{
							ID = 162;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size18;
								TextColor3 = Color3.new(0,0,0);
								Text = "Workspace";
								Font = Enum.Font.SourceSans;
								Name = "Info";
								Position = UDim2.new(0,40,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								BackgroundTransparency = 1;
								TextSize = 18;
								Size = UDim2.new(1,-40,0,22);
							};
							Children = {};
						};
					};
				};
			};
		};
		{
			ID = 163;
			Type = "Frame";
			Properties = {
				BackgroundTransparency = 0.10000000149011612;
				Name = "RemoteDebugWindow";
				Position = UDim2.new(1,0,0,0);
				BorderColor3 = Color3.new(191/255,191/255,191/255);
				Size = UDim2.new(0,300,1,0);
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 164;
					Type = "Frame";
					Properties = {
						BorderColor3 = Color3.new(149/255,149/255,149/255);
						Size = UDim2.new(1,0,0,17);
						Name = "Header";
						BackgroundColor3 = Color3.new(233/255,233/255,233/255);
					};
					Children = {
						{
							ID = 165;
							Type = "TextLabel";
							Properties = {
								FontSize = Enum.FontSize.Size14;
								TextColor3 = Color3.new(0,0,0);
								Text = "Remote Debugger";
								Font = Enum.Font.SourceSans;
								BackgroundTransparency = 1;
								Position = UDim2.new(0,4,0,0);
								TextXAlignment = Enum.TextXAlignment.Left;
								TextSize = 14;
								Size = UDim2.new(1,-4,1,0);
							};
							Children = {};
						};
					};
				};
				{
					ID = 166;
					Type = "BindableFunction";
					Properties = {
						Name = "GetSetting";
					};
					Children = {};
				};
				{
					ID = 167;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size32;
						Text = "Have fun with remotes";
						BackgroundTransparency = 1;
						TextWrapped = true;
						Font = Enum.Font.SourceSans;
						Name = "Desc";
						Position = UDim2.new(0,0,0,20);
						Size = UDim2.new(1,0,0,40);
						BackgroundColor3 = Color3.new(1,1,1);
						TextSize = 32;
						TextWrap = true;
					};
					Children = {};
				};
			};
		};
		{
			ID = 168;
			Type = "Frame";
			Properties = {
				Draggable = true;
				Active = true;
				BorderColor3 = Color3.new(149/255,149/255,149/255);
				Name = "About";
				Position = UDim2.new(1,0,0,0);
				Size = UDim2.new(0,300,1,0);
				ZIndex = 2;
				BorderSizePixel = 0;
				BackgroundColor3 = Color3.new(233/255,233/255,233/255);
			};
			Children = {
				{
					ID = 169;
					Type = "ImageLabel";
					Properties = {
						ImageColor3 = Color3.new(49/51,49/51,49/51);
						Image = "rbxassetid://483437370";
						Name = "Sad";
						Position = UDim2.new(0,50,1,-250);
						BackgroundTransparency = 1;
						ZIndex = 2;
						Size = UDim2.new(0,200,0,200);
						BackgroundColor3 = Color3.new(1,1,1);
					};
					Children = {};
				};
				{
					ID = 170;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size28;
						Text = "By Moon";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,140,0,30);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Creator";
						Position = UDim2.new(0,80,0,300);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 28;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 171;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size60;
						Text = "DEX";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,100,0,60);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Title";
						Position = UDim2.new(0,100,0,150);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 60;
						TextWrap = true;
					};
					Children = {};
				};
				{
					ID = 172;
					Type = "TextLabel";
					Properties = {
						FontSize = Enum.FontSize.Size28;
						Text = "v3";
						BackgroundTransparency = 1;
						Size = UDim2.new(0,100,0,30);
						TextWrapped = true;
						Font = Enum.Font.SourceSansBold;
						Name = "Version";
						Position = UDim2.new(0,100,0,210);
						BackgroundColor3 = Color3.new(1,1,1);
						ZIndex = 2;
						TextSize = 28;
						TextWrap = true;
					};
					Children = {};
				};
			};
		};
		{
			ID = 173;
			Type = "ImageButton";
			Properties = {
				ImageColor3 = Color3.new(233/255,233/255,233/255);
				Image = "rbxassetid://1513966937";
				Name = "Toggle";
				Position = UDim2.new(1,0,0,0);
				Rotation = 180;
				Size = UDim2.new(0,40,0,40);
				BackgroundTransparency = 1;
				BackgroundColor3 = Color3.new(1,1,1);
			};
			Children = {
				{
					ID = 174;
					Type = "TextLabel";
					Properties = {
						TextWrapped = true;
						Text = "<";
						BackgroundColor3 = Color3.new(1,1,1);
						Rotation = 180;
						Font = Enum.Font.SourceSans;
						BackgroundTransparency = 1;
						Position = UDim2.new(0,2,0,10);
						FontSize = Enum.FontSize.Size24;
						Size = UDim2.new(0,30,0,30);
						TextSize = 24;
						TextWrap = true;
					};
					Children = {};
				};
			};
		};
		{
			ID = 175;
			Type = "Folder";
			Properties = {
				Name = "TempPastes";
			};
			Children = {};
		};
	};
};

local function Scan(item, parent)
	local obj = Instance.new(item.Type)
	if (item.ID) then
		local awaiting = awaitRef[item.ID]
		if (awaiting) then
			awaiting[1][awaiting[2]] = obj
			awaitRef[item.ID] = nil
		else
			partsWithId[item.ID] = obj
		end
	end
	for p,v in pairs(item.Properties) do
		if (type(v) == "string") then
			local id = tonumber(v:match("^_R:(%w+)_$"))
			if (id) then
				if (partsWithId[id]) then
					v = partsWithId[id]
				else
					awaitRef[id] = {obj, p}
					v = nil
				end
			end
		end
		obj[p] = v
        task.wait()
	end
	for _,c in pairs(item.Children) do
		Scan(c, obj)
        task.wait()
	end
	obj.Parent = parent
	return obj
end
Scan(root, owner.PlayerGui)
print("GUIDONE")
owner.PlayerGui:WaitForChild("Dex"):WaitForChild("TempPastes").Parent = game.LocalizationService
local Gui = owner.PlayerGui:WaitForChild("Dex")

local IntroFrame = Gui:WaitForChild("IntroFrame")

local SideMenu = Gui:WaitForChild("SideMenu")
local OpenToggleButton = Gui:WaitForChild("Toggle")
local CloseToggleButton = SideMenu:WaitForChild("Toggle")
local OpenScriptEditorButton = SideMenu:WaitForChild("OpenScriptEditor")

local ScriptEditor = Gui:WaitForChild("ScriptEditor")

local SlideOut = SideMenu:WaitForChild("SlideOut")
local SlideFrame = SlideOut:WaitForChild("SlideFrame")
local Slant = SideMenu:WaitForChild("Slant")

local ExplorerButton = SlideFrame:WaitForChild("Explorer")
local SettingsButton = SlideFrame:WaitForChild("Settings")

local SelectionBox = Instance.new("SelectionBox")
SelectionBox.Parent = Gui

local ExplorerPanel = Gui:WaitForChild("ExplorerPanel")
local PropertiesFrame = Gui:WaitForChild("PropertiesFrame")
local SaveMapWindow = Gui:WaitForChild("SaveMapWindow")
local RemoteDebugWindow = Gui:WaitForChild("RemoteDebugWindow")

local SettingsPanel = Gui:WaitForChild("SettingsPanel")
local AboutPanel = Gui:WaitForChild("About")
local SettingsListener = SettingsPanel:WaitForChild("GetSetting")
local SettingTemplate = SettingsPanel:WaitForChild("SettingTemplate")
local SettingList = SettingsPanel:WaitForChild("SettingList")

local SaveMapCopyList = SaveMapWindow:WaitForChild("CopyList")
local SaveMapSettingFrame = SaveMapWindow:WaitForChild("MapSettings")
local SaveMapName = SaveMapWindow:WaitForChild("FileName")
local SaveMapButton = SaveMapWindow:WaitForChild("Save")
local SaveMapCopyTemplate = SaveMapWindow:WaitForChild("Entry")
local SaveMapSettings = {
	CopyWhat = {
		Workspace = true,
		Lighting = true,
		ReplicatedStorage = true,
		ReplicatedFirst = true,
		StarterPack = true,
		StarterGui = true,
		StarterPlayer = true
	},
	SaveScripts = true,
	SaveTerrain = true,
	LightingProperties = true,
	CameraInstances = true
}

--[[
local ClickSelectOption = SettingsPanel:WaitForChild("ClickSelect"):WaitForChild("Change")
local SelectionBoxOption = SettingsPanel:WaitForChild("SelectionBox"):WaitForChild("Change")
local ClearPropsOption = SettingsPanel:WaitForChild("ClearProperties"):WaitForChild("Change")
local SelectUngroupedOption = SettingsPanel:WaitForChild("SelectUngrouped"):WaitForChild("Change")
--]]

local SelectionChanged = ExplorerPanel:WaitForChild("SelectionChanged")
local GetSelection = ExplorerPanel:WaitForChild("GetSelection")
local SetSelection = ExplorerPanel:WaitForChild("SetSelection")

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local CurrentWindow = "Nothing c:"
local Windows = {
	Explorer = {
		ExplorerPanel,
		PropertiesFrame
	},
	Settings = {SettingsPanel},
	SaveMap = {SaveMapWindow},
	Remotes = {RemoteDebugWindow},
	About = {AboutPanel},
}

function switchWindows(wName,over)
	if CurrentWindow == wName and not over then return end
	
	local count = 0
	
	for i,v in pairs(Windows) do
		count = 0
		if i ~= wName then
			for _,c in pairs(v) do c:TweenPosition(UDim2.new(1, 30, count * 0.5, count * 36), "Out", "Quad", 0.5, true) count = count + 1 end
		end
	end
	
	count = 0
	
	if Windows[wName] then
		for _,c in pairs(Windows[wName]) do c:TweenPosition(UDim2.new(1, -300, count * 0.5, count * 36), "Out", "Quad", 0.5, true) count = count + 1 end
	end
	
	if wName ~= "Nothing c:" then
		CurrentWindow = wName
		for i,v in pairs(SlideFrame:GetChildren()) do
			v.BackgroundTransparency = 1
			v.Icon.ImageColor3 = Color3.new(70/255, 70/255, 70/255)
		end
		if SlideFrame:FindFirstChild(wName) then
			SlideFrame[wName].BackgroundTransparency = 0.5
			SlideFrame[wName].Icon.ImageColor3 = Color3.new(0,0,0)
		end
	end
end

function toggleDex(on)
	if on then
		SideMenu:TweenPosition(UDim2.new(1, -330, 0, 0), "Out", "Quad", 0.5, true)
		OpenToggleButton:TweenPosition(UDim2.new(1,0,0,0), "Out", "Quad", 0.5, true)
		switchWindows(CurrentWindow,true)
	else
		SideMenu:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
		OpenToggleButton:TweenPosition(UDim2.new(1,-40,0,0), "Out", "Quad", 0.5, true)
		switchWindows("Nothing c:")
	end
end

local Settings = {
	ClickSelect = false,
	SelBox = false,
	ClearProps = false,
	SelectUngrouped = true,
	SaveInstanceScripts = true
}

function ReturnSetting(set)
	if set == "ClearProps" then
		return Settings.ClearProps
	elseif set == "SelectUngrouped" then
		return Settings.SelectUngrouped
	end
end

OpenToggleButton.MouseButton1Up:connect(function()
	toggleDex(true)
end)

OpenScriptEditorButton.MouseButton1Up:connect(function()
	if OpenScriptEditorButton.Active then
		ScriptEditor.Visible = true
	end
end)

CloseToggleButton.MouseButton1Up:connect(function()
	if CloseToggleButton.Active then
		toggleDex(false)
	end
end)

--[[
OpenToggleButton.MouseButton1Up:connect(function()
	SideMenu:TweenPosition(UDim2.new(1, -330, 0, 0), "Out", "Quad", 0.5, true)
	
	if CurrentWindow == "Explorer" then
		ExplorerPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
		PropertiesFrame:TweenPosition(UDim2.new(1, -300, 0.5, 36), "Out", "Quad", 0.5, true)
	else
		SettingsPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
	end
	
	OpenToggleButton:TweenPosition(UDim2.new(1,0,0,0), "Out", "Quad", 0.5, true)
end)

CloseToggleButton.MouseButton1Up:connect(function()
	SideMenu:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
	
	ExplorerPanel:TweenPosition(UDim2.new(1, 30, 0, 0), "Out", "Quad", 0.5, true)
	PropertiesFrame:TweenPosition(UDim2.new(1, 30, 0.5, 36), "Out", "Quad", 0.5, true)
	SettingsPanel:TweenPosition(UDim2.new(1, 30, 0, 0), "Out", "Quad", 0.5, true)
	
	OpenToggleButton:TweenPosition(UDim2.new(1,-30,0,0), "Out", "Quad", 0.5, true)
end)
--]]

--[[
ExplorerButton.MouseButton1Up:connect(function()
	switchWindows("Explorer")
end)

SettingsButton.MouseButton1Up:connect(function()
	switchWindows("Settings")
end)
--]]

for i,v in pairs(SlideFrame:GetChildren()) do
	v.MouseButton1Click:connect(function()
		switchWindows(v.Name)
	end)
	
	v.MouseEnter:connect(function()v.BackgroundTransparency = 0.5 end)
	v.MouseLeave:connect(function()if CurrentWindow~=v.Name then v.BackgroundTransparency = 1 end end)
end

--[[
ExplorerButton.MouseButton1Up:connect(function()
	if CurrentWindow ~= "Explorer" then
		CurrentWindow = "Explorer"
		
		ExplorerPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
		PropertiesFrame:TweenPosition(UDim2.new(1, -300, 0.5, 36), "Out", "Quad", 0.5, true)
		SettingsPanel:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
	end
end)

SettingsButton.MouseButton1Up:connect(function()
	if CurrentWindow ~= "Settings" then
		CurrentWindow = "Settings"
		
		ExplorerPanel:TweenPosition(UDim2.new(1, 0, 0, 0), "Out", "Quad", 0.5, true)
		PropertiesFrame:TweenPosition(UDim2.new(1, 0, 0.5, 36), "Out", "Quad", 0.5, true)
		SettingsPanel:TweenPosition(UDim2.new(1, -300, 0, 0), "Out", "Quad", 0.5, true)
	end
end)
--]]

function createSetting(name,interName,defaultOn)
	local newSetting = SettingTemplate:Clone()
	newSetting.Position = UDim2.new(0,0,0,#SettingList:GetChildren() * 60)
	newSetting.SName.Text = name
	
	local function toggle(on)
		if on then
			newSetting.Change.Bar:TweenPosition(UDim2.new(0,32,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Change.OnBar:TweenSize(UDim2.new(0,34,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Status.Text = "On"
			Settings[interName] = true
		else
			newSetting.Change.Bar:TweenPosition(UDim2.new(0,-2,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Change.OnBar:TweenSize(UDim2.new(0,0,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			newSetting.Status.Text = "Off"
			Settings[interName] = false
		end
	end	
	
	newSetting.Change.MouseButton1Click:connect(function()
		toggle(not Settings[interName])
	end)
	
	newSetting.Visible = true
	newSetting.Parent = SettingList
	
	if defaultOn then
		toggle(true)
	end
end

createSetting("Click part to select","ClickSelect",false)
createSetting("Selection Box","SelBox",false)
createSetting("Clear property value on focus","ClearProps",false)
createSetting("Select ungrouped models","SelectUngrouped",true)
createSetting("SaveInstance decompiles scripts","SaveInstanceScripts",true)

--[[
ClickSelectOption.MouseButton1Up:connect(function()
	if Settings.ClickSelect then
		Settings.ClickSelect = false
		ClickSelectOption.Text = "OFF"
	else
		Settings.ClickSelect = true
		ClickSelectOption.Text = "ON"
	end
end)

SelectionBoxOption.MouseButton1Up:connect(function()
	if Settings.SelBox then
		Settings.SelBox = false
		SelectionBox.Adornee = nil
		SelectionBoxOption.Text = "OFF"
	else
		Settings.SelBox = true
		SelectionBoxOption.Text = "ON"
	end
end)

ClearPropsOption.MouseButton1Up:connect(function()
	if Settings.ClearProps then
		Settings.ClearProps = false
		ClearPropsOption.Text = "OFF"
	else
		Settings.ClearProps = true
		ClearPropsOption.Text = "ON"
	end
end)

SelectUngroupedOption.MouseButton1Up:connect(function()
	if Settings.SelectUngrouped then
		Settings.SelectUngrouped = false
		SelectUngroupedOption.Text = "OFF"
	else
		Settings.SelectUngrouped = true
		SelectUngroupedOption.Text = "ON"
	end
end)
--]]

local function getSelection()
	local t = GetSelection:Invoke()
	if t and #t > 0 then
		return t[1]
	else
		return nil
	end
end

Mouse.Button1Down:connect(function()
	if CurrentWindow == "Explorer" and Settings.ClickSelect then
		local target = Mouse.Target
		if target then
			SetSelection:Invoke({target})
		end
	end
end)

SelectionChanged.Event:connect(function()
	if Settings.SelBox then
		local success,err = pcall(function()
			local selection = getSelection()
			SelectionBox.Adornee = selection
		end)
		if err then
			SelectionBox.Adornee = nil
		end
	end
end)

SettingsListener.OnInvoke = ReturnSetting

-- Map Copier

function createMapSetting(obj,interName,defaultOn)
	local function toggle(on)
		if on then
			obj.Change.Bar:TweenPosition(UDim2.new(0,32,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Change.OnBar:TweenSize(UDim2.new(0,34,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Status.Text = "On"
			SaveMapSettings[interName] = true
		else
			obj.Change.Bar:TweenPosition(UDim2.new(0,-2,0,-2),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Change.OnBar:TweenSize(UDim2.new(0,0,0,15),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.25,true)
			obj.Status.Text = "Off"
			SaveMapSettings[interName] = false
		end
	end	
	
	obj.Change.MouseButton1Click:connect(function()
		toggle(not SaveMapSettings[interName])
	end)
	
	obj.Visible = true
	obj.Parent = SaveMapSettingFrame
	
	if defaultOn then
		toggle(true)
	end
end

function createCopyWhatSetting(serv)
	if SaveMapSettings.CopyWhat[serv] then
		local newSetting = SaveMapCopyTemplate:Clone()
		newSetting.Position = UDim2.new(0,0,0,#SaveMapCopyList:GetChildren() * 22 + 5)
		newSetting.Info.Text = serv
		
		local function toggle(on)
			if on then
				newSetting.Change.enabled.Visible = true
				SaveMapSettings.CopyWhat[serv] = true
			else
				newSetting.Change.enabled.Visible = false
				SaveMapSettings.CopyWhat[serv] = false
			end
		end	
	
		newSetting.Change.MouseButton1Click:connect(function()
			toggle(not SaveMapSettings.CopyWhat[serv])
		end)
		
		newSetting.Visible = true
		newSetting.Parent = SaveMapCopyList
	end
end

createMapSetting(SaveMapSettingFrame.Scripts,"SaveScripts",true)
createMapSetting(SaveMapSettingFrame.Terrain,"SaveTerrain",true)
createMapSetting(SaveMapSettingFrame.Lighting,"LightingProperties",true)
createMapSetting(SaveMapSettingFrame.CameraInstances,"CameraInstances",true)

createCopyWhatSetting("Workspace")
createCopyWhatSetting("Lighting")
createCopyWhatSetting("ReplicatedStorage")
createCopyWhatSetting("ReplicatedFirst")
createCopyWhatSetting("StarterPack")
createCopyWhatSetting("StarterGui")
createCopyWhatSetting("StarterPlayer")

SaveMapName.Text = tostring(game.PlaceId).."MapCopy"

SaveMapButton.MouseButton1Click:connect(function()
	local copyWhat = {}

	local copyGroup = Instance.new("Model",game:GetService('ReplicatedStorage'))

	local copyScripts = SaveMapSettings.SaveScripts

	local copyTerrain = SaveMapSettings.SaveTerrain

	local lightingProperties = SaveMapSettings.LightingProperties

	local cameraInstances = SaveMapSettings.CameraInstances

	-----------------------------------------------------------------------------------

	for i,v in pairs(SaveMapSettings.CopyWhat) do
		if v then
			table.insert(copyWhat,i)
		end
	end

	local consoleFunc = printconsole or writeconsole

	if consoleFunc then
		consoleFunc("Moon's place copier loaded.")
		consoleFunc("Copying map of game "..tostring(game.PlaceId)..".")
	end

	function archivable(root)
		for i,v in pairs(root:GetChildren()) do
			if not game:GetService('Players'):GetPlayerFromCharacter(v) then
				v.Archivable = true
				archivable(v)
			end
		end
	end

	function decompileS(root)
		for i,v in pairs(root:GetChildren()) do
			pcall(function()
				if v:IsA("LocalScript") then
					local isDisabled = v.Disabled
					v.Disabled = true
					v.Source = decompile(v)
					v.Disabled = isDisabled
				
					if v.Source == "" then 
						if consoleFunc then consoleFunc("LocalScript "..v.Name.." had a problem decompiling.") end
					else
						if consoleFunc then consoleFunc("LocalScript "..v.Name.." decompiled.") end
					end
				elseif v:IsA("ModuleScript") then
					v.Source = decompile(v)
				
					if v.Source == "" then 
						if consoleFunc then consoleFunc("ModuleScript "..v.Name.." had a problem decompiling.") end
					else
						if consoleFunc then consoleFunc("ModuleScript "..v.Name.." decompiled.") end
					end
				end
			end)
			decompileS(v)
		end
	end

	for i,v in pairs(copyWhat) do archivable(game[v]) end

	for j,obj in pairs(copyWhat) do
		if obj ~= "StarterPlayer" then
			local newFolder = Instance.new("Folder",copyGroup)
			newFolder.Name = obj
			for i,v in pairs(game[obj]:GetChildren()) do
				if v ~= copyGroup then
					pcall(function()
						v:Clone().Parent = newFolder
					end)
				end
			end
		else
			local newFolder = Instance.new("Model",copyGroup)
			newFolder.Name = "StarterPlayer"
			for i,v in pairs(game[obj]:GetChildren()) do
				local newObj = Instance.new("Folder",newFolder)
				newObj.Name = v.Name
				for _,c in pairs(v:GetChildren()) do
					if c.Name ~= "ControlScript" and c.Name ~= "CameraScript" then
						c:Clone().Parent = newObj
					end
				end
			end
		end
	end

	if workspace.CurrentCamera and cameraInstances then
		local cameraFolder = Instance.new("Model",copyGroup)
		cameraFolder.Name = "CameraItems"
		for i,v in pairs(workspace.CurrentCamera:GetChildren()) do v:Clone().Parent = cameraFolder end
	end

	if copyTerrain then
		local myTerrain = workspace.Terrain:CopyRegion(workspace.Terrain.MaxExtents)
		myTerrain.Parent = copyGroup
	end

	function saveProp(obj,prop,par)
		local myProp = obj[prop]
		if type(myProp) == "boolean" then
			local newProp = Instance.new("BoolValue",par)
			newProp.Name = prop
			newProp.Value = myProp
		elseif type(myProp) == "number" then
			local newProp = Instance.new("IntValue",par)
			newProp.Name = prop
			newProp.Value = myProp
		elseif type(myProp) == "string" then
			local newProp = Instance.new("StringValue",par)
			newProp.Name = prop
			newProp.Value = myProp
		elseif type(myProp) == "userdata" then -- Assume Color3
			pcall(function()
				local newProp = Instance.new("Color3Value",par)
				newProp.Name = prop
				newProp.Value = myProp
			end)
		end
	end

	if lightingProperties then
		local lightingProps = Instance.new("Model",copyGroup)
		lightingProps.Name = "LightingProperties"
	
		saveProp(game:GetService('Lighting'),"Ambient",lightingProps)
		saveProp(game:GetService('Lighting'),"Brightness",lightingProps)
		saveProp(game:GetService('Lighting'),"ColorShift_Bottom",lightingProps)
		saveProp(game:GetService('Lighting'),"ColorShift_Top",lightingProps)
		saveProp(game:GetService('Lighting'),"GlobalShadows",lightingProps)
		saveProp(game:GetService('Lighting'),"OutdoorAmbient",lightingProps)
		saveProp(game:GetService('Lighting'),"Outlines",lightingProps)
		saveProp(game:GetService('Lighting'),"GeographicLatitude",lightingProps)
		saveProp(game:GetService('Lighting'),"TimeOfDay",lightingProps)
		saveProp(game:GetService('Lighting'),"FogColor",lightingProps)
		saveProp(game:GetService('Lighting'),"FogEnd",lightingProps)
		saveProp(game:GetService('Lighting'),"FogStart",lightingProps)
	end

	if decompile and copyScripts then
		decompileS(copyGroup)
	end

	if SaveInstance then
		SaveInstance(copyGroup,SaveMapName.Text..".rbxm")
	elseif saveinstance then
		saveinstance(getelysianpath()..SaveMapName.Text..".rbxm",copyGroup)
	end
	--print("Saved!")
	if consoleFunc then
		consoleFunc("The map has been copied.")
	end
	SaveMapButton.Text = "The map has been saved"
	wait(5)
	SaveMapButton.Text = "Save"
end)

-- End Copier

wait()

IntroFrame:TweenPosition(UDim2.new(1,-301,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)

switchWindows("Explorer")

wait(1)

SideMenu.Visible = true

for i = 0,1,0.1 do
	IntroFrame.BackgroundTransparency = i
	IntroFrame.Main.BackgroundTransparency = i
	IntroFrame.Slant.ImageTransparency = i
	IntroFrame.Title.TextTransparency = i
	IntroFrame.Version.TextTransparency = i
	IntroFrame.Creator.TextTransparency = i
	IntroFrame.Sad.ImageTransparency = i
	wait()
end

IntroFrame.Visible = false

SlideFrame:TweenPosition(UDim2.new(0,0,0,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)
OpenScriptEditorButton:TweenPosition(UDim2.new(0,0,0,150),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)
CloseToggleButton:TweenPosition(UDim2.new(0,0,0,180),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)
Slant:TweenPosition(UDim2.new(0,0,0,210),Enum.EasingDirection.Out,Enum.EasingStyle.Quart,0.5,true)

wait(0.5)

for i = 1,0,-0.1 do
	OpenScriptEditorButton.Icon.ImageTransparency = i
	CloseToggleButton.TextTransparency = i
	wait()
end

CloseToggleButton.Active = true
CloseToggleButton.AutoButtonColor = true

OpenScriptEditorButton.Active = true
OpenScriptEditorButton.AutoButtonColor = true











NS('FEDex=function(a)local b=a.PlayerGui:WaitForChild("Dex")print(a)print("PastGui")local c=Instance.new("RemoteFunction",b)c.Name="DexAPI"local d=b:WaitForChild("TempPastes")d.Parent=game:GetService("Players"):WaitForChild(a)function RunRemote(...)local e={...}local f=e[1]table.remove(e,1)if e[1]=="EditProperty"then e[2][e[3]]=e[4]end;if e[1]=="Clone"then local g=e[2]:Clone()g.Parent=d;return g end;if e[1]=="PasteTo"then e[2]:Clone().Parent=e[3]end;if e[1]=="Duplicate"then e[2]:Clone().Parent=e[2].Parent end;if e[1]=="SwitchParents"then e[2].Parent=e[3]end;if e[1]=="Group"then local h=Instance.new("Model",e[2].Parent)e[2].Parent=h end;if e[1]=="UnGroup"then if e[2]:IsA("Model")then local h=e[2]for i,j in pairs(h:GetChildren())do j.Parent=h.Parent end;h:Destroy()end end;if e[1]=="Delete"then e[2]:Destroy()end;if e[1]=="GetChildren"then local k=game:WaitForChild(e[2])local l={}local m={}function ReturnTableDataFromClone(j,n,o)local p={}local q=j:Clone()pcall(function()if o then p=o end;if n then q.Parent=n end;for i,j in pairs(q:GetChildren())do j:Destroy()end;p[q]=j;for i,r in pairs(j:GetChildren())do ReturnTableDataFromClone(r,q,p)end end)return p,q end;for i,s in pairs(k:GetChildren())do local t=s:Clone()if t then local u,t=ReturnTableDataFromClone(s,nil,l)if t then table.insert(m,t)t.Parent=d end;if not string.match(t.ClassName,"Value")then t.Changed:connect(function(v)if v~="Parent"or t:IsDescendantOf(game.ServerStorage)or t:IsDescendantOf(game.ServerScriptService)then u[t][v]=t[v]else u[t].Parent=u[t.Parent]end end)else coroutine.wrap(function()while wait(2)do if u[t.Parent]then u[t].Parent=u[t.Parent]else u[t].Parent=t.Parent end;u[t].Name=t.Name;t.Changed:connect(function(w)u[t].Value=w end)end end)()end;for i,x in pairs(t:GetDescendants())do if not string.match(x.ClassName,"Value")then x.Changed:connect(function(v)if v~="Parent"or x:IsDescendantOf(game.ServerStorage)or x:IsDescendantOf(game.ServerScriptService)then pcall(function()u[x][v]=x[v]end)else pcall(function()u[x].Parent=u[x.Parent]end)end end)else coroutine.wrap(function()while wait(2)do if u[x.Parent]then u[x].Parent=u[x.Parent]else u[x].Parent=x.Parent end;u[x].Name=x.Name;x.Changed:connect(function(w)u[x].Value=w end)end end)()end end end end;return m end end;c.OnServerInvoke=RunRemote end;FEDex(owner)')