for _, module in script:GetChildren() do
	if module:IsA("ModuleScript") then
		task.spawn(function()
			require(module)
		end)
	end
end