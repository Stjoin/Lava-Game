local modules = {}

modules["rewards"] = require(script:WaitForChild("rewards"))
modules["gameplay"] = require(script:WaitForChild("gameplay"))
modules["data_templates"] = require(script:WaitForChild("data_templates"))
modules["animations"] = require(script:WaitForChild("animations"))
modules["items"] = require(script:WaitForChild("items"))
modules["drops"] = require(script:WaitForChild("drops"))
modules["customer_settings"] = require(script:WaitForChild("customer_settings"))
modules["settings"] = require(script:WaitForChild("settings"))
modules["decoration"] = require(script:WaitForChild("decoration"))
modules["tycoon"] = require(script:WaitForChild("tycoon"))
modules["synonyms"] = require(script:WaitForChild("synonyms"))
modules["leaderboards"] = require(script:WaitForChild("leaderboards"))
modules["upgrades"] = require(script:WaitForChild("upgrades"))
modules["timed_objects"] = require(script:WaitForChild("timed_objects"))
modules["pets"] = require(script:WaitForChild("pets"))
modules["rebirth"] = require(script:WaitForChild("rebirth"))

return modules