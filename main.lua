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
	bulletTimerLimit = 0.5
	bulletTimer = bulletTimerLimit
	bulletRadius = 5

	asteroidRadius = 80
	asteroidStages = {
		{
			speed = 120,
			radius = 15,
		},
		{
			speed = 70,
			radius = 30,
		},
		{
			speed = 50,
			radius = 50,
		},
		{
			speed = 20,
			radius = 80,
		},
	}
	asteroids = {
		{
			x = 100,
			y = 100,
			angle = math.random() * math.pi,
			stage = #asteroidStages,
		},
		{
			x = arenaWidth - 100,
			y = 100,
			angle = math.random() * math.pi,
			stage = #asteroidStages,
		},
		{
			x = arenaWidth / 2,
			y = arenaHeight - 100,
			angle = math.random() * math.pi,
			stage = #asteroidStages,
		},
	}
end

function love.draw()
	for y = -1, 1 do
		for x = -1, 1 do
			love.graphics.push()

			love.graphics.translate(x * arenaWidth, y * arenaHeight)

			-- [[ ship ]]
			love.graphics.setColor(0, 0, 1)
			love.graphics.circle("fill", shipX, shipY, shipRadius)
			-- inner circle
			local innerCircleDistance = 20
			love.graphics.setColor(0, 1, 1)
			love.graphics.circle(
				"fill",
				shipX + (innerCircleDistance * math.cos(shipAngle)),
				shipY + (innerCircleDistance * math.sin(shipAngle)),
				5
			)

			love.graphics.pop()

			-- bullets
			for _, bullet in ipairs(bullets) do
				love.graphics.setColor(0, 1, 0)
				love.graphics.circle("fill", bullet.x, bullet.y, bulletRadius)
			end

			-- asteroids
			for _, asteroid in ipairs(asteroids) do
				love.graphics.setColor(1, 1, 0)
				love.graphics.circle("fill", asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius)
			end
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
	if #asteroids == 0 then
		love.load()
	end

	-- ship
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

	-- bullets
	bulletTimer = bulletTimer + dt

	if love.keyboard.isDown("s") then
		if bulletTimer >= bulletTimerLimit then
			bulletTimer = 0

			table.insert(bullets, {
				x = shipX + math.cos(shipAngle) * shipRadius,
				y = shipY + math.sin(shipAngle) * shipRadius,
				angle = shipAngle,
			})
		end
	end

	local function areCirclesIntersecting(aX, aY, aRadius, bX, bY, bRadius)
		return (aX - bX) ^ 2 + (aY - bY) ^ 2 <= (aRadius + bRadius) ^ 2
	end

	for bulletIndex = #bullets, 1, -1 do
		local bullet = bullets[bulletIndex]
		local bulletSpeed = 500
		bullet.x = bullet.x + (math.cos(bullet.angle) * bulletSpeed * dt)
		bullet.y = bullet.y + (math.sin(bullet.angle) * bulletSpeed * dt)

		-- check for bullet collision with asteroid
		for asteroidIndex = #asteroids, 1, -1 do
			local asteroid = asteroids[asteroidIndex]

			if
				areCirclesIntersecting(bullet.x, bullet.y, bulletRadius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius)
			then
				table.remove(bullets, bulletIndex)

				if asteroid.stage > 1 then
					local angle1 = love.math.random() * (2 * math.pi)
					local angle2 = (angle1 - math.pi) % (2 * math.pi)

					table.insert(asteroids, {
						x = asteroid.x,
						y = asteroid.y,
						angle = angle1,
						stage = asteroid.stage - 1,
					})
					table.insert(asteroids, {
						x = asteroid.x,
						y = asteroid.y,
						angle = angle2,
						stage = asteroid.stage - 1,
					})
				end

				table.remove(asteroids, asteroidIndex)
				break
			end
		end
	end

	-- asteroids
	for _, asteroid in ipairs(asteroids) do
		local asteroidSpeed = asteroidStages[asteroid.stage].speed
		asteroid.x = (asteroid.x + (math.cos(asteroid.angle) * asteroidSpeed * dt)) % arenaWidth
		asteroid.y = (asteroid.y + (math.sin(asteroid.angle) * asteroidSpeed * dt)) % arenaHeight

		-- check for asteroid collision with ship then remove both
		if areCirclesIntersecting(shipX, shipY, shipRadius, asteroid.x, asteroid.y, asteroidStages[asteroid.stage].radius) then
			love.load()
			break
		end
	end
end
