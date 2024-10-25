for _, module in script:GetChildren() do
	require(module)
end

game.ReplicatedStorage.Networking.Bindables.LoadingFinished:Fire()