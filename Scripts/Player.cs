using Godot;
using System;
using System.Collections.Generic;

public partial class Player : Area2D
{
	[Export] public int GridSize = 5;
	[Export] public int CellSize = 64;

	public List<List<Plot>> Plots = new List<List<Plot>>(); // Reference to the grid as Plot objects, not generic Nodes
	public Vector2I CurrentCoordinates = new Vector2I(0, 0);
	public Vector2 TargetPosition;
	public Plot CurrentPlot = null; // Strongly typed Plot reference

	public override void _Ready()
	{
		// Initialize CurrentPlot
		CurrentPlot = Plots[CurrentCoordinates.X][CurrentCoordinates.Y];
		TargetPosition = CurrentPlot.GlobalPosition;
		GlobalPosition = TargetPosition;

		CurrentPlot.SetPlayer(this);
	}

	public override void _PhysicsProcess(double delta)
	{
		// Smooth movement toward TargetPosition
		Position = Position.MoveToward(TargetPosition, CellSize * 5 * (float)delta);
	}

	public override void _Input(InputEvent @event)
	{
		// Movement and planting logic based on input events
		if (@event.IsActionPressed("ui_up") || @event.IsActionPressed("up"))
		{
			Move(new Vector2I(0, -1));
		}
		else if (@event.IsActionPressed("ui_down") || @event.IsActionPressed("down"))
		{
			Move(new Vector2I(0, 1));
		}
		else if (@event.IsActionPressed("ui_left") || @event.IsActionPressed("left"))
		{
			Move(new Vector2I(-1, 0));
		}
		else if (@event.IsActionPressed("ui_right") || @event.IsActionPressed("right"))
		{
			Move(new Vector2I(1, 0));
		}
		else if (@event.IsActionPressed("plant1"))
		{
			PlantSeedOnCurrentPlot(PlantType.Carrot);
		}
		else if (@event.IsActionPressed("plant2"))
		{
			PlantSeedOnCurrentPlot(PlantType.Lettuce);
		}
		else if (@event.IsActionPressed("plant3"))
		{
			PlantSeedOnCurrentPlot(PlantType.Tomato);
		}
		else if (@event.IsActionPressed("harvest"))
		{
			HarvestPlantOnCurrentPlot();
		}
	}

	public void Move(Vector2I direction)
	{
		// Calculate new coordinates and check boundaries
		var newCoordinates = CurrentCoordinates + direction;
		if (newCoordinates.X >= 0 && newCoordinates.X < GridSize && newCoordinates.Y >= 0 && newCoordinates.Y < GridSize)
		{
			// Update current and new plot references
			CurrentPlot?.RemovePlayer();
			CurrentCoordinates = newCoordinates;
			CurrentPlot = Plots[CurrentCoordinates.X][CurrentCoordinates.Y];

			// Position player on the new plot
			CurrentPlot.SetPlayer(this);
			TargetPosition = CurrentPlot.GlobalPosition;
		}
	}

	// Plant a seed on the current plot
	public void PlantSeedOnCurrentPlot(PlantType plantType)
	{
		if (CurrentPlot == null || CurrentPlot.HasPlant())
		{
			GD.Print("Cannot plant: Plot already occupied or invalid.");
			return;
		}

		// Load the appropriate plant scene based on PlantType
		string plantScenePath = plantType switch
		{
			PlantType.Carrot => "res://plants/Carrot.tscn",
			PlantType.Lettuce => "res://plants/Lettuce.tscn",
			PlantType.Tomato => "res://plants/Tomato.tscn",
			_ => "res://plants/Plant.tscn" // Default or generic plant
		};

		var packedScene = GD.Load<PackedScene>(plantScenePath);
		if (packedScene == null)
		{
			GD.PrintErr($"Failed to load plant scene: {plantScenePath}");
			return;
		}

		// Instantiate the plant and assign its type
		var plantInstance = packedScene.Instantiate<Plant>();
		plantInstance.Type = plantType;

		// Add the plant to the plot
		CurrentPlot.SetPlant(plantInstance);
		CurrentPlot.AddChild(plantInstance);

		// Position the plant visually on the plot
		plantInstance.GlobalPosition = CurrentPlot.GlobalPosition;
		GD.Print($"Planted a {plantType}!");
	}

	public void HarvestPlantOnCurrentPlot()
	{
		if (CurrentPlot == null || !CurrentPlot.HasPlant())
		{
			GD.Print("Cannot harvest: No plant present on the plot.");
			return;
		}

		var plant = CurrentPlot.GetPlant();
		if (plant.IsFullyGrown())
		{
			// Remove the plant from the grid
			CurrentPlot.RemovePlant();
			CurrentPlot.RemoveChild(plant);

			GD.Print("Plant harvested successfully!");
		}
		else
		{
			GD.Print("Cannot harvest: Plant is not fully grown.");
		}
	}

	public void MoveTo(int x, int y)
	{
		if (x < 0 || x >= GridSize || y < 0 || y >= GridSize) return;

		// Update position and plot references
		CurrentPlot?.RemovePlayer();
		CurrentCoordinates = new Vector2I(x, y);
		CurrentPlot = Plots[CurrentCoordinates.X][CurrentCoordinates.Y];

		CurrentPlot.SetPlayer(this);
		TargetPosition = CurrentPlot.GlobalPosition;
	}
}
