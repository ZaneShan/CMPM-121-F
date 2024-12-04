using Godot;
using System.Collections.Generic;

public partial class Plant : Node2D
{
	public int GrowthLevel { get; private set; } = 0;
	public int MaxGrowthLevel { get; private set; } = 2;
	public Plot CurrentPlot { get; set; }
	
	[Export] public float SunReq { get; set; } = 1.0f;
	[Export] public float WaterReq { get; set; } = 1.0f;
	
	// Plant type flags
	[Export] public bool IsLettuce { get; set; } = false;
	[Export] public bool IsCarrot { get; set; } = false;
	[Export] public bool IsTomato { get; set; } = false;

	// References to the plant stage sprites
	private Sprite2D plantStage1;
	private Sprite2D plantStage2;
	private Sprite2D plantStage3;

	public override void _Ready()
	{
		// Get references to the child Sprite nodes for each growth stage
		plantStage1 = GetNode<Sprite2D>("plant_stage_1");
		plantStage2 = GetNode<Sprite2D>("plant_stage_2");
		plantStage3 = GetNode<Sprite2D>("plant_stage_3");
		plantStage1.Visible = true;
		plantStage2.Visible = false;
		plantStage3.Visible = false;

		// Set the initial visibility
		UpdatePlantGrowth();
	}

	public void UpdatePlant(Plant plant, Plot plot)
	{
		// Check if the plant meets growth requirements
		if (plot.SunLevel >= plant.SunReq && plot.WaterLevel >= plant.WaterReq)
		{
			if (GrowthLevel < MaxGrowthLevel)
			{
				if (plant.Grow())
				{
					GrowthLevel++;
					UpdatePlantGrowth();
				}
			}
		}
		GD.Print("Plant growth level: ", GrowthLevel);
	}

	public bool Grow()
	{
		// Conditional growth logic based on plant type
		if (IsLettuce)
		{
			// Lettuce can only grow near other lettuce
			if (!CheckIfNear("Lettuce", CurrentPlot))
				return false;
		}
		else if (IsTomato)
		{
			// Tomato can only grow when alone, having any plants adjacent prohibits growth
			if (CheckIfNear("Lettuce", CurrentPlot) ||
				CheckIfNear("Carrot", CurrentPlot) ||
				CheckIfNear("Tomato", CurrentPlot))
				return false;
		}
		else if (IsCarrot)
		{
			// Carrots can only grow near other types (not themselves), or by themselves
			if (CheckIfNear("Carrot", CurrentPlot))
				return false;
		}
		return true;
	}

	// Checks if the plant is fully grown
	public bool IsFullyGrown()
	{
		return GrowthLevel == MaxGrowthLevel;
	}

	private void UpdatePlantGrowth()
	{
		plantStage1.Visible = GrowthLevel == 0;
		plantStage2.Visible = GrowthLevel == 1;
		plantStage3.Visible = GrowthLevel == 2;
	}

	private bool CheckIfNear(string plantType, Plot currentPlot)
	{
		if (currentPlot == null)
		{
			GD.PrintErr("Error: currentPlot is null!");
			return false;
		}

		List<Plot> nearbyPlots = currentPlot.GetAdjacentPlots();

		// Check each adjacent plot for a plant of the given type
		foreach (var plot in nearbyPlots)
		{
			if (plot.HasPlant())
			{
				var plant = plot.GetPlant();

				// Check if the plant type matches
				if (plantType == "Carrot" && plant.IsCarrot)
					return true;
				else if (plantType == "Lettuce" && plant.IsLettuce)
					return true;
				else if (plantType == "Tomato" && plant.IsTomato)
					return true;
			}
		}

		// If no matching plants were found
		return false;
	}
}
