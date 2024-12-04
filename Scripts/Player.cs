using Godot;
using System;
using System.Collections.Generic;

public partial class Player : Area2D
{
	[Export]
	public int GridSize = 5;

	[Export]
	public int CellSize = 64;

	public List<List<Node>> Plots = new List<List<Node>>(); // Reference to the plot grid
	public Vector2I CurrentCoordinates = new Vector2I(0, 0);
	public Vector2 TargetPosition;
	public Node CurrentPlot = null; // Holds current plot under player

	public override void _Ready()
	{
		CurrentPlot = Plots[CurrentCoordinates.X][CurrentCoordinates.Y];
		TargetPosition = ((Node2D)CurrentPlot).GlobalPosition;
		GlobalPosition = TargetPosition;

		// Assuming the plot has a "SetPlayer" method
		CurrentPlot.Call("set_player", this);
	}

	public override void _PhysicsProcess(double delta)
	{
		Position = Position.MoveToward(TargetPosition, CellSize * 5 * (float)delta);
	}

	public override void _Input(InputEvent @event)
	{
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
		else if (@event.IsActionPressed("ui_accept"))
		{
			PlantSeedOnCurrentPlot(""); // Specify the plant type here (e.g., "Carrot")
		}
		else if (@event.IsActionPressed("plant1"))
		{
			PlantSeedOnCurrentPlot("Carrot");
		}
		else if (@event.IsActionPressed("plant2"))
		{
			PlantSeedOnCurrentPlot("Lettuce");
		}
		else if (@event.IsActionPressed("plant3"))
		{
			PlantSeedOnCurrentPlot("Tomato");
		}
		else if (@event.IsActionPressed("harvest"))
		{
			HarvestPlantOnCurrentPlot();
		}
	}

	public void Move(Vector2I direction)
	{
		var newCoordinates = CurrentCoordinates + direction;

		if (newCoordinates.X >= 0 && newCoordinates.X < GridSize && newCoordinates.Y >= 0 && newCoordinates.Y < GridSize)
		{
			((Node)CurrentPlot).Call("remove_player");

			CurrentCoordinates = newCoordinates;
			CurrentPlot = Plots[CurrentCoordinates.X][CurrentCoordinates.Y];

			CurrentPlot.Call("set_player", this);
			TargetPosition = ((Node2D)CurrentPlot).GlobalPosition;
		}
	}

	public void MoveTo(int x, int y)
	{
		((Node)CurrentPlot).Call("remove_player");

		CurrentCoordinates = new Vector2I(x, y);
		CurrentPlot = Plots[CurrentCoordinates.X][CurrentCoordinates.Y];

		CurrentPlot.Call("set_player", this);
		TargetPosition = ((Node2D)CurrentPlot).GlobalPosition;
	}

	public void PlantSeedOnCurrentPlot(string plantType)
	{
		Node currentPlant = null;

		switch (plantType)
		{
			case "Carrot":
				currentPlant = GD.Load<PackedScene>("res://plants/Carrot.tscn").Instantiate();
				break;
			case "Lettuce":
				currentPlant = GD.Load<PackedScene>("res://plants/Lettuce.tscn").Instantiate();
				break;
			case "Tomato":
				currentPlant = GD.Load<PackedScene>("res://plants/Tomato.tscn").Instantiate();
				break;
			default:
				currentPlant = GD.Load<PackedScene>("res://plants/Plant.tscn").Instantiate(); // Default value
				break;
		}

		// Set plant type flags (if applicable)
		currentPlant.Set("is_carrot", plantType == "Carrot");
		currentPlant.Set("is_lettuce", plantType == "Lettuce");
		currentPlant.Set("is_tomato", plantType == "Tomato");

		if ((bool)CurrentPlot.Call("has_plant") == false)
		{
			CurrentPlot.Call("set_plant", currentPlant);
			((Node)CurrentPlot).AddChild(currentPlant);

			((Node2D)currentPlant).GlobalPosition = ((Node2D)CurrentPlot).GlobalPosition;
			currentPlant.Set("current_plot", CurrentPlot);

			// Notify parent node to encode the grid (if method exists)
			var parentNode = GetParent();
			if (parentNode.HasMethod("encode_current_grid"))
			{
				parentNode.Call("encode_current_grid");
			}
		}
	}

	public void HarvestPlantOnCurrentPlot()
	{
		if (CurrentPlot != null)
		{
			if ((bool)CurrentPlot.Call("has_plant"))
			{
				var plant = (Node)CurrentPlot.Call("get_plant");

				if ((bool)plant.Call("is_fully_grown"))
				{
					CurrentPlot.RemoveChild(plant);
					CurrentPlot.Call("remove_plant");
					GD.Print("Plant harvested.");
				}
				else
				{
					GD.Print("Current plot plant is not fully grown.");
				}
			}
			else
			{
				GD.Print("Current plot does not have a plant.");
			}
		}
		else
		{
			GD.Print("Current plot is null when harvesting.");
		}
	}
}
