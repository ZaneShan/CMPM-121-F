using Godot;
using System;
using System.Collections.Generic;

public partial class Plot : Node2D
{
	[Export] public float SunLevel = 0.0f; // Current sun energy level in the plot
	[Export] public float WaterLevel = 10.0f; // Current water level in the plot

	private Vector2 _sunLevelRange = new Vector2(5, 10); // Random sun level range for each turn
	private Vector2 _waterChangeRange = new Vector2(-2, 2); // Random water change range for each turn

	public Plant Plant { get; private set; } = null; // Optional plant object
	public Node2D Player { get; private set; } = null; // Reference to the player on this plot
	public Vector2 Coordinates { get; set; }

	private static PackedScene _plotScene = GD.Load<PackedScene>("res://Plot.tscn");
	private static PackedScene _playerScene = GD.Load<PackedScene>("res://Player.tscn");

	private List<List<Plot>> _plotsArray = new();

	// Returns true if there is a plant in the plot
	public bool HasPlant() => Plant != null;

	// Sets the plant in the plot
	public void SetPlant(Plant newPlant)
	{
		Plant = newPlant;
	}
	
	public Plant GetPlant()
	{
		return Plant;
	}

	// Removes the plant from the plot
	public void RemovePlant()
	{
		Plant = null;
	}

	// Sets the player in the plot
	public void SetPlayer(Node2D newPlayer)
	{
		Player = newPlayer;
	}

	// Removes the player from the plot
	public void RemovePlayer()
	{
		Player = null;
	}

	// Updates the individual plot
	public void UpdatePlot(Plot plot)
	{
		// Randomize sun and water levels
		plot.SunLevel = (float)GD.RandRange(_sunLevelRange.X, _sunLevelRange.Y);
		plot.WaterLevel += (float)GD.RandRange(_waterChangeRange.X, _waterChangeRange.Y);

		// Clamp water level to reasonable bounds
		plot.WaterLevel = Mathf.Clamp(plot.WaterLevel, 0, 20);

		// Update the plant in the plot, if any
		if (plot.HasPlant() && plot.Plant is Plant plant)
		{
			plant.UpdatePlant(plant, plot);
		}
	}

	// Static method to create the grid
	public static List<List<Plot>> CreateGrid(int gridSize, int cellSize, Node2D parent)
	{
		var plots = new List<List<Plot>>();

		// Get the size of the viewport
		Vector2 viewportSize = parent.GetViewportRect().Size;
		float gridWidth = gridSize * cellSize;
		float gridHeight = gridSize * cellSize;

		float startX = (viewportSize.X - gridWidth) / 2;
		float startY = (viewportSize.Y - gridHeight) / 2;

		// Create grid matrix
		for (int x = 0; x < gridSize; x++)
		{
			var row = new List<Plot>();
			for (int y = 0; y < gridSize; y++)
			{
				var plot = (Plot)_plotScene.Instantiate();
				parent.AddChild(plot);

				plot.Position = new Vector2(startX + x * cellSize, startY + y * cellSize);
				plot.Coordinates = new Vector2(x, y);
				row.Add(plot);
			}
			plots.Add(row);
		}

		return plots;
	}

	// Clears the grid and deletes all nodes, including the player
	public static void ClearGrid(Node2D parent, List<List<Plot>> plotsArray)
	{
		// Delete all plot nodes in the grid
		foreach (var row in plotsArray)
		{
			foreach (var plot in row)
			{
				plot.QueueFree();
			}
		}

		// Clear the plot array
		plotsArray.Clear();

		// Check if there are player nodes and delete them
		if (parent.HasNode("Player"))
		{
			var playerNode = parent.GetNode("Player");
			playerNode.QueueFree();
		}

		if (parent.HasNode("Player2"))
		{
			var player2Node = parent.GetNode("Player2");
			player2Node.QueueFree();
		}

		GD.Print("Grid cleared and player deleted.");
	}

	// Sets the plots array explicitly when creating the grid
	public void SetPlotsArray(List<List<Plot>> newPlotsArray)
	{
		_plotsArray = newPlotsArray;
	}

	// Gets adjacent plots
	public List<Plot> GetAdjacentPlots()
	{
		var adjacentPlots = new List<Plot>();
		int currentX = (int)Coordinates.X;
		int currentY = (int)Coordinates.Y;

		if (_plotsArray.Count == 0) return adjacentPlots;

		int gridSizeX = _plotsArray.Count;
		int gridSizeY = _plotsArray[0].Count;

		// Ensure coordinates are within bounds of the grid
		if (currentX > 0)
			adjacentPlots.Add(_plotsArray[currentX - 1][currentY]); // Left
		if (currentX < gridSizeX - 1)
			adjacentPlots.Add(_plotsArray[currentX + 1][currentY]); // Right
		if (currentY > 0)
			adjacentPlots.Add(_plotsArray[currentX][currentY - 1]); // Up
		if (currentY < gridSizeY - 1)
			adjacentPlots.Add(_plotsArray[currentX][currentY + 1]); // Down

		return adjacentPlots;
	}

	// Example method to instantiate a player in a plot
	public static Node2D PlacePlayer(List<List<Plot>> grid, int x, int y, Node2D parent)
	{
		var player = (Node2D)_playerScene.Instantiate();
		parent.AddChild(player);

		player.Name = "Player";
		player.GlobalPosition = grid[x][y].GlobalPosition;

		return player;
	}
}
