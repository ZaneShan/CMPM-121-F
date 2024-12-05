using Godot;
using System.Collections.Generic;
using System.Linq;
// Define the possible plant types
public enum PlantType
{
	Lettuce,
	Tomato,
	Carrot
}

// Define an interface for all growth rules
public interface IGrowthRule
{
	bool CanGrow(Plant plant, Plot plot);
}

// Define growth rules as modular classes
public class LettuceGrowthRule : IGrowthRule
{
	public bool CanGrow(Plant plant, Plot plot)
	{
		// Lettuce grows only when near other Lettuce
		return plot.GetAdjacentPlots()
			.Any(adjacent => adjacent.HasPlant() && adjacent.GetPlant().Type == PlantType.Lettuce);
	}
}

public class TomatoGrowthRule : IGrowthRule
{
	public bool CanGrow(Plant plant, Plot plot)
	{
		// Tomato can only grow when no plants of any type are nearby
		return !plot.GetAdjacentPlots()
			.Any(adjacent => adjacent.HasPlant());
	}
}

public class CarrotGrowthRule : IGrowthRule
{
	public bool CanGrow(Plant plant, Plot plot)
	{
		// Carrots cannot grow near other Carrots
		return !plot.GetAdjacentPlots()
			.Any(adjacent => adjacent.HasPlant() && adjacent.GetPlant().Type == PlantType.Carrot);
	}
}

public partial class Plant : Node2D
{
	public PlantType Type { get; set; } // Added PlantType property
	
	// General plant attributes
	public int GrowthLevel { get; set; } = 0;
	public int MaxGrowthLevel { get; set; } = 2;
	public Plot CurrentPlot { get; set; }

	[Export] public float SunReq { get; set; } = 1.0f; // Sunlight requirement
	[Export] public float WaterReq { get; set; } = 1.0f; // Water requirement

	// References to sprites for visual growth stages
	private Sprite2D plantStage1;
	private Sprite2D plantStage2;
	private Sprite2D plantStage3;

	private List<IGrowthRule> growthRules = new List<IGrowthRule>();

	public override void _Ready()
	{
		// Initialize visual elements
		plantStage1 = GetNode<Sprite2D>("plant_stage_1");
		plantStage2 = GetNode<Sprite2D>("plant_stage_2");
		plantStage3 = GetNode<Sprite2D>("plant_stage_3");

		// Set initial visibility
		UpdatePlantGrowth();
	}

	// Adds a growth rule to the plant
	public void AddGrowthRule(IGrowthRule rule)
	{
		growthRules.Add(rule);
	}

	// Determines whether the plant meets all growth criteria
	public bool CanGrow()
	{
		if (CurrentPlot == null)
		{
			GD.PrintErr("Current plot is null!");
			return false;
		}

		// Check all growth rules
		foreach (var rule in growthRules)
		{
			// If any rule is not satisfied, plant cannot grow
			if (!rule.CanGrow(this, CurrentPlot))
				return false;
		}

		// Check environmental thresholds (Sun and Water requirements)
		return CurrentPlot.SunLevel >= SunReq && CurrentPlot.WaterLevel >= WaterReq;
	}

	// Trigger plant growth if possible
	public void Grow()
	{
		if (CanGrow() && GrowthLevel < MaxGrowthLevel)
		{
			GrowthLevel++;
			UpdatePlantGrowth();
			GD.Print($"{this.Name} grew to level {GrowthLevel}!");
		}
	}

	// Check if the plant is fully grown
	public bool IsFullyGrown()
	{
		return GrowthLevel == MaxGrowthLevel;
	}
	
	// Updates which sprite is visible based on growth level
	private void UpdatePlantGrowth()
	{
		plantStage1.Visible = GrowthLevel == 0;
		plantStage2.Visible = GrowthLevel == 1;
		plantStage3.Visible = GrowthLevel == 2;
	}
}
