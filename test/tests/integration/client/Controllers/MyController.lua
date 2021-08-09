local Knit = require(game:GetService("ReplicatedStorage").Knit)
local Comm = require(Knit.Util.Comm)
local Option = require(Knit.Util.Option)
local Ser = require(Knit.Util.Ser)


local MyController = Knit.CreateController { Name = "MyController" }


function MyController:KnitStart()
	local MyService = Knit.GetService("MyService")
	local msg = MyService:GetMessage()
	print("Message from MyService: " .. msg)
	for _ = 1,3 do
		MyService:MaybeGetRandomNumber():Match {
			Some = function(num)
				print("Got random number: " .. num)
			end;
			None = function()
				print("Did not get a random number")
			end;
		}
	end

	local comm = Comm.Client.ForParent(workspace, true, "TestNS")
	local Add = comm:GetFunction("Add", {Ser.DeserializeMiddleware(Option)}, {Ser.SerializeMiddleware(Option)})
	local a = Option.Some(10)
	local b = Option.Some(20)
	Add(a, b):Then(function(c)
		print("PROMISE: " .. a:Unwrap() .. " + " .. b:Unwrap() .. " = " .. c:Unwrap())
	end):Catch(warn)

	local sig = comm:GetSignal("TestSignal", {Ser.DeserializeMiddleware(Option)}, {Ser.SerializeMiddleware(Option)})
	sig:Connect(function(opt)
		print("Client received message: " .. opt:Unwrap())
	end)
	sig:Fire(Option.Some("Hello!"))

end


function MyController:KnitInit()
end


return MyController