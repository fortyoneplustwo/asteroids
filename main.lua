function love.load()
	arenaWidth = 800
	arenaHeight = 600

	shipX = arenaWidth / 2
	shipY = arenaHeight / 2

	shipAngle = 0
	shipRadius = 30
	turnRate = 10

	shipSpeedX = 0
	shipSpeedY = 0

	bullets = {}
end

function love.keypressed(key)
	if key == "s" then
		table.insert(bullets, {
			x = shipX + math.cos(shipAngle) * shipRadius,
			y = shipY + math.sin(shipAngle) * shipRadius,
			angle = shipAngle,
		})
	end
end

function love.draw()
	for y = -1, 1 do
		for x = -1, 1 do
			love.graphics.push()
			love.graphics.translate(x * arenaWidth, y * arenaHeight)

			love.graphics.setColor(0, 0, 1)
			love.graphics.circle("fill", shipX, shipY, shipRadius)

			local innerCircleDistance = 20
			love.graphics.setColor(1, 0, 0)
			love.graphics.circle(
				"fill",
				shipX + (innerCircleDistance * math.cos(shipAngle)),
				shipY + (innerCircleDistance * math.sin(shipAngle)),
				5
			)

			for bulletIndex, bullet in ipairs(bullets) do
				love.graphics.setColor(0, 1, 0)
				love.graphics.circle("fill", bullet.x, bullet.y, 5)
			end

			love.graphics.pop()
		end
	end

	-- Temporary
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("shipAngle: " .. shipAngle)

	love.graphics.setColor(1, 1, 1)
	love.graphics.print(table.concat({
		"shipAngle: " .. shipAngle,
		"shipX: " .. shipX,
		"shipY: " .. shipY,
		"shipSpeedX: " .. shipSpeedX,
		"shipSpeedY: " .. shipSpeedY,
	}, "\n"))
end

function love.update(dt)
	if love.keyboard.isDown("up") then
		local shipSpeed = 100
		shipSpeedX = shipSpeedX + (math.cos(shipAngle) * shipSpeed * dt)
		shipSpeedY = shipSpeedY + (math.sin(shipAngle) * shipSpeed * dt)
	end

	if love.keyboard.isDown("right") then
		shipAngle = shipAngle + (turnRate * dt)
		shipAngle = shipAngle % (2 * math.pi)
	end

	if love.keyboard.isDown("left") then
		shipAngle = shipAngle - (turnRate * dt)
		shipAngle = shipAngle % (2 * math.pi)
	end

	shipX = (shipX + shipSpeedX * dt) % arenaWidth
	shipY = (shipY + shipSpeedY * dt) % arenaHeight

	for bulletIndex, bullet in ipairs(bullets) do
		local bulletSpeed = 10
		bullet.x = (bullet.x + (bulletSpeed * dt))
		bullet.y = (bullet.y + (bulletSpeed * dt))
	end

end
