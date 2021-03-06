require("lib/TSerial")

local nodeManager = {}

nodeManager.init = function()
	nodeManager.list = dofile("data/default.lua")
	nodeManager.drag = nil
	nodeManager.node = nil
	nodeManager.out = nil
	nodeManager.outX = 0
	nodeManager.outY = 0
	nodeManager.mouseX = 0
	nodeManager.mouseY = 0
	nodeManager.scale = 1
	nodeManager.scroll = false
	nodeManager.scrollX = 0
	nodeManager.scrollY = 0
	nodeManager.selectedNode = nil
	nodeManager.selectedName = nil
	nodeManager.selectedText = nil

	love.graphics.setLineWidth(3)
	love.graphics.setDefaultFilter("nearest", "nearest")
  
	nodeManager.font = love.graphics.newFont("font/font.ttf", 16)
	love.graphics.setFont(nodeManager.font)
end

nodeManager.update = function(dt)
	local cnt = 0
	
	for k, v in pairs(nodeManager.list) do
		local cnt2 = 0
		if v.out then
			for k2, v2 in pairs(v.out) do
				v2.x = v.x + v.width - 12
				v2.y = v.y + cnt2 * 16 + 40
				cnt2 = cnt2 + 1
			end
		end
		
		cnt = cnt + 1
	end
end

nodeManager.draw = function()
	love.graphics.setBlendMode("alpha")
	love.graphics.scale(nodeManager.scale, nodeManager.scale)
	love.graphics.translate(nodeManager.scrollX, nodeManager.scrollY)

	for k, v in pairs(nodeManager.list) do
		local cnt = 0
    v.height = 72
    
    if not v._text then
      v._text = love.graphics.newText(nodeManager.font)
    end
    
    if v.out then
      v.height = v.height + #v.out * 16
    end
    
    v.height = v.height + v._text:getHeight()
		
		if nodeManager.selectedNode == v then
			love.graphics.setColor(255, 127, 0)
		else
			love.graphics.setColor(127, 127, 127)
		end

		love.graphics.rectangle("fill", v.x - 2, v.y - 2, v.width + 4, v.height + 4, 6)
		if nodeManager.selectedNode == v then
			love.graphics.setColor(127, 63, 0)
		else
			love.graphics.setColor(63, 63, 63)
		end
    love.graphics.rectangle("fill", v.x - 1, v.y - 1, v.width + 2, v.height + 2, 6)

		love.graphics.setColor(191, 191, 191)
		love.graphics.rectangle("fill", v.x, v.y, v.width, v.height, 6)
		if nodeManager.selectedNode == v then
			love.graphics.setColor(127, 63, 0)
		else
			love.graphics.setColor(63, 63, 63)
		end

		love.graphics.rectangle("fill", v.x, v.y, v.width, 24, 6)
    love.graphics.rectangle("fill", v.x, v.y + 12, v.width, 12)
		love.graphics.setColor(223, 223, 223)
		love.graphics.printf(k, v.x, v.y + 4, v.width, "center")
		love.graphics.setColor(223, 223, 223)
		love.graphics.printf("x", v.x, v.y + 4, v.width - 8, "right")
		love.graphics.setColor(63, 63, 63)
		love.graphics.circle("fill", v.x + 12, v.y + v.height * 0.5, 7, 16)
		love.graphics.setColor(223, 223, 223)
		love.graphics.circle("fill", v.x + 12, v.y + v.height * 0.5, 5, 16)

		if v.out then
			for k2, v2 in pairs(v.out) do
				if nodeManager.selectedNode == v and nodeManager.selectedText == cnt + 1 then
					love.graphics.setColor(191, 63, 0)
					love.graphics.printf(v2.name .. "_", v.x, v2.y - 8, v.width - 32, "right")
				else
					if v2.name == "ANSWER" then
						love.graphics.setColor(159, 159, 159)
					else
						love.graphics.setColor(31, 31, 31)
					end
          
          if string.len(v2.name) < 24 then
            love.graphics.printf(v2.name, v.x + 8, v2.y - 8, v.width - 32, "right")
          else
            love.graphics.printf(string.sub(v2.name, 0, 20) .. "...", v.x + 8, v2.y - 8, v.width - 32, "right")
          end
				end
				love.graphics.setColor(63, 63, 63)
				love.graphics.circle("fill", v2.x, v2.y, 7, 16)
				love.graphics.setColor(223, 223, 223)
				love.graphics.circle("fill", v2.x, v2.y, 5, 16)
				
				cnt = cnt + 1
			end
		end
		love.graphics.setColor(0, 127, 255)
		love.graphics.printf("New  +", v.x, v.y + cnt * 16 + 32, v.width - 8, "right")
		cnt = cnt + 1

		love.graphics.setColor(63, 63, 63)
		love.graphics.rectangle("fill", v.x + 24, v.y + cnt * 16 + 40, v.width - 32, v.height - cnt * 16 - 48)

		if nodeManager.selectedNode == v and nodeManager.selectedText == 0 then
			love.graphics.setColor(255, 127, 0)
      v._text:setf(v.text .. "_", v.width - 36, "left")
      love.graphics.draw(v._text, v.x + 28, v.y + cnt * 16 + 44)
		else
			if v.text == "TEXT" then
				love.graphics.setColor(127, 127, 127)
			else
				love.graphics.setColor(223, 223, 223)
			end

      v._text:setf(v.text, v.width - 36, "left")
      love.graphics.draw(v._text, v.x + 28, v.y + cnt * 16 + 44)
		end
	end
	
	for k, v in pairs(nodeManager.list) do
		love.graphics.setColor(0, 127, 255)
		if v.out then
			for k2, v2 in pairs(v.out) do
				if v2.node and nodeManager.list[v2.node] then
					local bezier = love.math.newBezierCurve(
						v2.x, v2.y,
            v2.x + 64, v2.y,
						nodeManager.list[v2.node].x + 12 - 64, nodeManager.list[v2.node].y + nodeManager.list[v2.node].height * 0.5,
            nodeManager.list[v2.node].x + 12, nodeManager.list[v2.node].y + nodeManager.list[v2.node].height * 0.5
          )
          
          love.graphics.line(
						bezier:render()
					)
					
					love.graphics.setColor(0, 127, 255)
					love.graphics.circle("fill", v2.x, v2.y, 4, 16)
				
					love.graphics.setColor(0, 127, 255)
					love.graphics.circle("fill", nodeManager.list[v2.node].x + 12, nodeManager.list[v2.node].y + nodeManager.list[v2.node].height * 0.5, 4, 16)
				end
			end
		end
	end

	if nodeManager.node then
		love.graphics.setColor(255, 127, 0)
		love.graphics.circle("fill", nodeManager.outX , nodeManager.outY, 4, 16)
		local bezier = love.math.newBezierCurve(
			nodeManager.outX, nodeManager.outY,
      nodeManager.outX + 64, nodeManager.outY,
			nodeManager.mouseX - 64, nodeManager.mouseY,
      nodeManager.mouseX, nodeManager.mouseY
    )
    
    love.graphics.line(
      bezier:render()
		)

		for k, v in pairs(nodeManager.list) do
			if nodeManager.node ~= k and nodeManager.mouseX >= v.x and nodeManager.mouseX <= v.x + v.width and nodeManager.mouseY >= v.y and nodeManager.mouseY <= v.y + v.height then
				love.graphics.circle("fill", v.x + 12, v.y + v.height * 0.5, 4, 16)
				break
			end
		end
	end
	
	love.graphics.setColor(255, 255, 255)
	love.graphics.origin()
	
	love.graphics.print("Save (F5)", love.graphics.getWidth() - 128, 16)
	love.graphics.print("Load (F7)", love.graphics.getWidth() - 128, 32)
	love.graphics.print("Reset (F9)", love.graphics.getWidth() - 128, 48)
end

nodeManager.mousepressed = function(x, y, button)
	local mx = x / nodeManager.scale - nodeManager.scrollX
	local my = y / nodeManager.scale - nodeManager.scrollY
	
	if nodeManager.selectedNode and nodeManager.selectedText then
		if nodeManager.selectedText == 0 and nodeManager.selectedNode.text == "" then
			nodeManager.selectedNode.text = "TEXT"
		elseif nodeManager.selectedNode.out and nodeManager.selectedNode.out[nodeManager.selectedText] and nodeManager.selectedNode.out[nodeManager.selectedText].name == "" then
			nodeManager.selectedNode.out[nodeManager.selectedText].name = "ANSWER"
		end
	end
	
	nodeManager.selectedNode = nil
	nodeManager.selectedName = nil
	nodeManager.selectedText = nil
	
	if button == 1 or button == 2 then
		for k, v in pairs(nodeManager.list) do
			local cnt = 0

			if mx >= v.x and mx <= v.x + v.width and my >= v.y and my <= v.y + v.height then
				if my <= v.y + 24 then
					if mx <= v.x + v.width - 24 then
						nodeManager.drag = k
						nodeManager.dragX = v.x - mx
						nodeManager.dragY = v.y - my
					else
						nodeManager.list[k] = nil
					end
				elseif v.out then
					for k2, v2 in pairs(v.out) do
						if mx >= v.x + v.width - 18 and mx <= v.x + v.width - 6 and my >= v.y + cnt * 16 + 34 and my <= v.y + cnt * 16 + 46 then
							if button == 1 then
								nodeManager.node = k
								nodeManager.out = k2
								
								nodeManager.outX = v.x + v.width - 12
								nodeManager.outY = v.y + cnt * 16 + 40
								nodeManager.mouseX = nodeManager.outX
								nodeManager.mouseY = nodeManager.outY
							elseif button == 2 then
								v2.node = ""
							end
						end

						cnt = cnt + 1
					end
				end
				
				nodeManager.selectedNode = v
				nodeManager.selectedName = k
				
				if button == 1 then
					if mx >= v.x + 24 and mx <= v.x + v.width and my >= v.y + cnt * 16 + 34 and my <= v.y + cnt * 16 + 46 then
						local out = {}
						
						out.name = "ANSWER"
						
						if nodeManager.list[k].out then
							table.insert(nodeManager.list[k].out, out)
						else
							nodeManager.list[k].out = {out}
						end

						break
					end
				end
				
				cnt = cnt + 1
				
				if mx >= v.x + 24 and my >= v.y + cnt * 16 + 40 and mx <= v.x + 24 + v.width - 32 and my <= v.y + cnt * 16 + 40 + v.height - cnt * 16 - 48 then
					nodeManager.selectedText = 0
					if nodeManager.selectedNode.text == "TEXT"  then
						nodeManager.selectedNode.text = ""
					end
				elseif v.out then
					local cnt2 = 0
					for k2, v2 in pairs(v.out) do
						if mx >= v.x + 24 and mx <= v.x + v.width - 24 and my >= v.y + cnt2 * 16 + 34 and my <= v.y + cnt2 * 16 + 46 then
							if button == 1 then
								nodeManager.selectedText = cnt2 + 1

								if v2.name == "ANSWER" then
									v2.name = ""
								end
							elseif button == 2 then
								table.remove(nodeManager.list[k].out, cnt2 + 1)
							end

							break
						end
						cnt2 = cnt2 + 1
					end
				end
				
				break
			end
		end
	elseif button == 3 then
		nodeManager.scroll = true
	end
end

nodeManager.mousereleased = function(x, y, button)
	local mx = x / nodeManager.scale - nodeManager.scrollX
	local my = y / nodeManager.scale - nodeManager.scrollY
	nodeManager.drag = nil
	
	if nodeManager.node then
		local connect = false
		
		for k, v in pairs(nodeManager.list) do
			if mx >= v.x and mx <= v.x + v.width and my >= v.y and my <= v.y + v.height then
        if nodeManager.node ~= k then
          nodeManager.list[nodeManager.node].out[nodeManager.out].node = k
        end
				connect = true
				break
			end
		end
		
		if not connect then
			local node = nodeManager.addNode(mx, my)
			
			nodeManager.list[nodeManager.node].out[nodeManager.out].node = node
		end
	end
	
	nodeManager.node = nil
	nodeManager.out = nil
	
	nodeManager.scroll = false
end

nodeManager.mousemoved = function(x, y, dx, dy)
	local mx = x / nodeManager.scale - nodeManager.scrollX
	local my = y / nodeManager.scale - nodeManager.scrollY

	if nodeManager.drag then
		nodeManager.list[nodeManager.drag].x = mx + nodeManager.dragX
		nodeManager.list[nodeManager.drag].y = my + nodeManager.dragY
	end
	
	nodeManager.mouseX = mx
	nodeManager.mouseY = my
	
	if nodeManager.scroll then
		nodeManager.scrollX = math.floor(nodeManager.scrollX + dx / nodeManager.scale)
		nodeManager.scrollY = math.floor(nodeManager.scrollY + dy / nodeManager.scale)
	end
end

nodeManager.wheelmoved = function(x, y)
	if y < 0 and nodeManager.scale > 0.5 then
		nodeManager.scrollX = nodeManager.scrollX + 80 / nodeManager.scale
		nodeManager.scrollY = nodeManager.scrollY + 60 / nodeManager.scale
		nodeManager.scale = nodeManager.scale - 0.5
	elseif y > 0 and nodeManager.scale < 2 then
		nodeManager.scrollX = nodeManager.scrollX - 80 / nodeManager.scale
		nodeManager.scrollY = nodeManager.scrollY - 60 / nodeManager.scale
		nodeManager.scale = nodeManager.scale + 0.5
	end
end

nodeManager.keypressed = function(key)
	if key == "+" and not nodeManager.selectedText then
		nodeManager.addNode(nodeManager.mouseX, nodeManager.mouseY)
	elseif key == "backspace" then
		if nodeManager.selectedNode and nodeManager.selectedText then
			if nodeManager.selectedText == 0 then
				nodeManager.selectedNode.text = string.sub(nodeManager.selectedNode.text, 0, string.len(nodeManager.selectedNode.text) - 1)
			else
				nodeManager.selectedNode.out[nodeManager.selectedText].name = string.sub(nodeManager.selectedNode.out[nodeManager.selectedText].name, 0, string.len(nodeManager.selectedNode.out[nodeManager.selectedText].name) - 1)
			end
		end
	elseif key == "delete" then
		if nodeManager.selectedNode then
			if nodeManager.selectedText and nodeManager.selectedText >= 1 then
				table.remove(nodeManager.list[nodeManager.selectedName].out, nodeManager.selectedText)
			elseif not nodeManager.selectedText then
				nodeManager.list[nodeManager.selectedName] = nil
			end
		end
	elseif key == "f5" then
		local data = TSerial.pack_pretty(nodeManager.list)
		local dir = love.filesystem.getSourceBaseDirectory()

		local file = io.open(arg[1] .. "/data/save.lua", "w")

		if file then
			file:write("return " .. data)
			file:close()
		end
	elseif key == "f7" then
		nodeManager.list = dofile("data/save.lua")
	elseif key == "f9" then
		nodeManager.list = dofile("data/default.lua")
	end
end

nodeManager.textinput = function(text)
	if nodeManager.selectedNode and nodeManager.selectedText then
		if nodeManager.selectedText == 0 then
			nodeManager.selectedNode.text = nodeManager.selectedNode.text .. text
		else
			nodeManager.selectedNode.out[nodeManager.selectedText].name = nodeManager.selectedNode.out[nodeManager.selectedText].name .. text
		end
	end
end

nodeManager.addNode = function(x, y, parent)
	local node = {}

	node.width = 256
	node.height = 191
	node.x = math.floor(x - 12)
	node.y = math.floor(y - 44)
	node.text = "TEXT"
	
	for i = 1, 999 do
		if not nodeManager.list["node" .. i]  then
			nodeManager.list["node" .. i] = node
			return "node" .. i
		end
	end
end

return nodeManager