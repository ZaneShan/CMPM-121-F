using Godot;
using System.Collections.Generic;
using System.Linq;

public partial class Main : Node2D
{
	private int gridSize = 3;
	List<List<Plot>> plotsArray = new List<List<Plot>>();
	
	private PackedScene plotScene = GD.Load<PackedScene>("res://Plot.gd");
	
	private List<byte[]> undoStack = new List<byte[]>();
	private List<byte[]> redoStack = new List<byte[]>();

	public override void _Ready()
	{
		CheckAutosave();
		// Create the grid using the Plot static method
		int cellSize = 64;
		plotsArray = Plot.CreateGrid(gridSize, cellSize, this);
		
		// Setup UI components
		var levelCompleteLabel = GetNode<Label>("LevelCompleteLabel");
		levelCompleteLabel.Visible = false;

		var viewportSize = GetViewportRect().Size;
		levelCompleteLabel.Position = plotsArray[0][0].GlobalPosition;
		
		// Assign the grid to each plot
		foreach (var row in plotsArray)
		{
			foreach (var plot in row)
			{
				plot.SetPlotsArray(plotsArray);
			}
		}

		// Connect buttons
		ConnectButton("TurnButton", nameof(OnTurnComplete));
		ConnectButton("SaveButton", nameof(Save), "save1");
		ConnectButton("SaveButton2", nameof(Save), "save2");
		ConnectButton("SaveButton3", nameof(Save), "save3");
		ConnectButton("LoadButton", nameof(Load), "save1");
		ConnectButton("LoadButton2", nameof(Load), "save2");
		ConnectButton("LoadButton3", nameof(Load), "save3");
		ConnectButton("UndoButton", nameof(Undo));
		ConnectButton("RedoButton", nameof(Redo));
		ConnectButton("AutosaveButton", nameof(LoadAutosave));
		ConnectButton("AutosaveCloseButton", nameof(HideAutosavePrompt));

		// Add the player
		var player = GD.Load<PackedScene>("res://Player.tscn").Instantiate<Player>();
		player.Plots = plotsArray;
		player.GridSize = gridSize;
		AddChild(player);

		// Set player starting position
		if (gridSize > 0)
		{
			player.Position = plotsArray[0][0].Position;
		}

		EncodeCurrentGrid(); // Save the initial game state to undo stack
	}

	private void ConnectButton(string buttonPath, string methodName, string parameter = null)
	{
		var button = GetNode<Button>(buttonPath);
		if (parameter != null)
			button.Pressed += () => Call(methodName, parameter);
		else
			button.Pressed += () => Call(methodName);
	}

	private void ShowAutosavePrompt()
	{
		GetNode<Label>("AutosaveLabel").Visible = true;
		GetNode<Button>("AutosaveButton").Visible = true;
		GetNode<Button>("AutosaveCloseButton").Visible = true;
	}

	private void HideAutosavePrompt()
	{
		GetNode<Label>("AutosaveLabel").Visible = false;
		GetNode<Button>("AutosaveButton").Visible = false;
		GetNode<Button>("AutosaveCloseButton").Visible = false;
	}

	private void OnTurnComplete()
	{
		foreach (var row in plotsArray)
		{
			foreach (var plot in row)
			{
				plot.UpdatePlot(plot);
			}
		}

		EncodeCurrentGrid();
		CheckLevelComplete();
		Autosave();
		HideAutosavePrompt();
	}

	private void CheckAutosave()
	{
		if (!FileAccess.FileExists("user://grid_autosave.dat"))
		{
			GD.Print("No autosave file found");
			return;
		}
		ShowAutosavePrompt();
	}

	private void Autosave()
	{
		using var file = FileAccess.Open("user://grid_autosave.dat", FileAccess.ModeFlags.Write);
		if (file == null)
		{
			GD.Print("Failed to open file for saving!");
			return;
		}

		// Save grid state
		var encodedData = Plot.EncodeGrid(plotsArray, this);
		file.Store32((uint)encodedData.Length);
		file.StoreBuffer(encodedData);

		// Save undo stack
		file.Store32((uint)undoStack.Count);
		foreach (var state in undoStack)
		{
			file.Store32((uint)state.Length);
			file.StoreBuffer(state);
		}

		// Save redo stack
		file.Store32((uint)redoStack.Count);
		foreach (var state in redoStack)
		{
			file.Store32((uint)state.Length);
			file.StoreBuffer(state);
		}

		GD.Print("Grid data and stacks saved successfully!");
	}

	private void LoadAutosave()
	{
		HideAutosavePrompt();
		using var file = FileAccess.Open("user://grid_autosave.dat", FileAccess.ModeFlags.Read);
		if (file == null)
		{
			GD.Print("Failed to open file for loading!");
			return;
		}

		// Load grid state
		var gridSize = file.Get32();
		var encodedData = file.GetBuffer(gridSize);
		Plot.ClearGrid(this, plotsArray);
		plotsArray = Plot.DecodeGrid(encodedData, this);

		// Load undo stack
		undoStack.Clear();
		var undoStackSize = file.Get32();
		for (int i = 0; i < undoStackSize; i++)
		{
			var stateSize = file.Get32();
			undoStack.Add(file.GetBuffer(stateSize));
		}

		// Load redo stack
		redoStack.Clear();
		var redoStackSize = file.Get32();
		for (int i = 0; i < redoStackSize; i++)
		{
			var stateSize = file.Get32();
			redoStack.Add(file.GetBuffer(stateSize));
		}

		GD.Print("Grid data and stacks loaded successfully!");
		CheckLevelComplete();
	}

	private void Save(string fileName)
	{
		// Similar to Autosave, but saves to a different file based on `fileName`
	}

	private void Load(string fileName)
	{
		// Similar to LoadAutosave, but loads from a file based on `fileName`
	}

	private void Undo()
	{
		if (undoStack.Count > 0)
		{
			var lastState = undoStack[^1];
			undoStack.RemoveAt(undoStack.Count - 1);

			Plot.ClearGrid(this, plotsArray);
			plotsArray = Plot.DecodeGrid(lastState, this);

			redoStack.Add(lastState);
			CheckLevelComplete();

			GD.Print("Undo: Grid restored to previous state.");
		}
		else
		{
			GD.Print("No more actions to undo.");
		}
	}

	private void Redo()
	{
		if (redoStack.Count > 0)
		{
			var redoState = redoStack[^1];
			redoStack.RemoveAt(redoStack.Count - 1);

			Plot.ClearGrid(this, plotsArray);
			plotsArray = Plot.DecodeGrid(redoState, this);

			undoStack.Add(redoState);
			CheckLevelComplete();

			GD.Print("Redo: Grid restored to the next state.");
		}
		else
		{
			GD.Print("No more actions to redo.");
		}
	}

	private void EncodeCurrentGrid()
	{
		var encodedData = Plot.EncodeGrid(plotsArray, this);
		undoStack.Add(encodedData);
		redoStack.Clear(); // Clear redo stack when a new action occurs
		GD.Print("Current grid state encoded and pushed to undo stack.");
	}

	private void CheckLevelComplete()
	{
		int grownPlants = 0;
		foreach (var row in plotsArray)
		{
			foreach (var plot in row)
			{
				if (plot.HasPlant() && plot.GetPlant().IsFullyGrown())
				{
					grownPlants++;
				}
			}
		}

		var levelCompleteLabel = GetNode<Label>("LevelCompleteLabel");
		if (grownPlants >= 5) // Example win condition
		{
			GD.Print("Level Complete!");
			levelCompleteLabel.Visible = true;
		}
		else
		{
			levelCompleteLabel.Visible = false;
		}
	}
}
