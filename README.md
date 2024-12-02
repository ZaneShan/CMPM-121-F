# Devlog Entry 1 - 11/15/2024

## Introducing the Team
**Tools Lead:**  
Zane Shan  
**Engine Lead:**  
James Yim  
**Design Lead:**  
Leif Tanner  

---

## Tools and Materials

### Engines, Libraries, Frameworks, and Platforms
We plan to use **Godot**. Godot has a lot of built-in functionality, and we do not perceive the need for outside libraries or frameworks.

### Programming and Data Languages
We plan to use **C#** and **GDScript**. GDScript is built for Godot and has extensive functionality for game development.

### Tools for Authoring the Project
- **IDE:** VSCode, because it is what we are accustomed to.  
- **Image Editor:** Aseprite, as we plan to create pixel art and already own Aseprite.  

### Alternate Platform Choice
Our alternate platform will be **Unity**, as it differs significantly from Godot. It relies more heavily on **C#** or **C++**, rather than GDScript.

---

## Outlook

### Unique Goals
Our team aims to challenge ourselves by programming in **GDScript**, an unfamiliar language, despite being more comfortable with **C#**. This sets us apart as most teams might stick to what they know best.

### Anticipated Challenges
The most difficult part of the project will be the **learning curve**:
- Adapting to a new engine, **Godot**.
- Learning and applying **GDScript**, Godot’s scripting language.

### Learning Objectives
We aim to:
- Master scripting with **GDScript**.
- Familiarize ourselves with Godot’s unique **scene system** and **user interface navigation**.  
If time permits, we plan to:
- Create custom sprites and assets in **Aseprite** and import them into the game.

--- 

# Devlog Entry 2 - 11/27/2024

## How we satisfied the software requirements
### [F0.a] You control a character moving over a 2D grid.
We implemented a controllable character that moves using arrow keys. We created a placeholder farmer sprite in Aseprite to represent the player object.

### [F0.b] You advance time manually in the turn-based simulation.
We implemented a pressable button that advances time forward by a day. It changes water and sun values on the grid cells (we call them plots in the code) for every new day, then calls a grow method on existing plants which checks if criteria (water, sun, spatial rules) are met for the next growth stage.

### [F0.c] You can reap or sow plants on grid cells only when you are near them.
The player model can only plant and harvest crops they are directly above.

### [F0.d] Grid cells have sun and water levels. Each cell's incoming sun and water is somehow randomly generated each turn. Sun energy cannot be stored in a cell (it is used immediately or lost) while water moisture can be slowly accumulated over several turns.
Every grid cell has a respective water and sun integer which plants reference when they are growing. The sun values are random, while water levels accumulate, adding a random value to its total. Here is how these values are calculated each day:
plot.sun_level = randf_range(sun_level_range.x, sun_level_range.y)
plot.water_level += randf_range(water_change_range.x, water_change_range.y)

### [F0.e] Each plant on the grid has a distinct type (e.g. one of 3 species) and a growth level (e.g. “level 1”, “level 2”, “level 3”).
We have three plants all inheriting a base “plant” class, each with distinctive rules governing their growth and unique placeholder sprites. They can grow up to stage 3, after which the player can harvest them.

### [F0.f] Simple spatial rules govern plant growth based on sun, water, and nearby plants (satisfying conditions unlock growth).
Beyond water and sun requirements for every plant, there are unique rules plants must follow to grow: lettuce can only grow near other lettuce, tomato can only grow when alone, having any plants adjacent prohibits growth, and carrots can only grow near other types other than themselves, or by themselves.

### [F0.g] A play scenario is completed when some condition is satisfied (e.g. at least X plants at growth level Y or above).
We are currently working on a scenario where players must achieve a certain number of plants at growth level 3 to complete a scenario.

## Reflection
We haven’t changed the tools for the project, but our use of role titles has been very lenient. Since two in our group do not have experience in Godot and are eager to learn the engine and Godot’s native scripting language, (and since Godot packages most of its libraries together) we haven't been coordinating in terms of art direction and tools. In actuality, the only role that has been consistent is the production/design lead, which is Leif. We have not been using VSCode for our IDE as well; Godot has a native IDE built into its UI, which we are using.

--- 

# Devlog Entry 3 - 12/2/2024

## How we satisfied the software requirements

### [F0.a] You control a character moving over a 2D grid.
Same as last week.

### [F0.b] You advance time manually in the turn-based simulation.
Same as last week.

### [F0.c] You can reap or sow plants on grid cells only when you are near them.
Same as last week.

### [F0.d] Grid cells have sun and water levels. Each cell's incoming sun and water is somehow randomly generated each turn. Sun energy cannot be stored in a cell (it is used immediately or lost) while water moisture can be slowly accumulated over several turns.
Same as last week.

### [F0.e] Each plant on the grid has a distinct type (e.g. one of 3 species) and a growth level (e.g. “level 1”, “level 2”, “level 3”).
Same as last week.

### [F0.f] Simple spatial rules govern plant growth based on sun, water, and nearby plants (satisfying conditions unlock growth).
Same as last week.

### [F0.g] A play scenario is completed when some condition is satisfied (e.g. at least X plants at growth level Y or above).
Same as last week.

### [F1.a] The important state of your game's grid must be backed by a single contiguous byte array in AoS or SoA format. If your game stores the grid state in multiple format, the byte array format must be the primary format (i.e. other formats are decoded from it as needed).
For the contiguous byte array we used an array of structures. We do this because we have multiple plots so each plot is its own structure where information such as sun level and water level but also info such as if there is a plant or player on the plot. In Godot we used the function PackedByteArray. It made it easy in that it gave the structure we wanted already so it made it very easy for us to implement our contiguoys byte array.

### [F1.b] The player must be able to manually save their progress in the game. This must allow them to load state and continue play another day (i.e. after quitting the game app). The player must be able to manage multiple save files/slots.
The player is able to save their progres manually by way of three different save slots. Each of these saves to their own specific file and is able to be loaded individually as needed by the player. We use the function FileAccess.open() to open files and save the data to the file.

### [F1.c] The game must implement an implicit auto-save system to support recovery from unexpected quits. (For example, when the game is launched, if an auto-save entry is present, the game might ask the player "do you want to continue where you left off?" The auto-save entry might or might not be visible among the list of manual save entries available for the player to load as part of F1.b.)
We refactored our save function for the manual save and translated so that it works seemlessly for auto saving. We autosave every time there is a new turn in order to save big changes. We have a prompt that asks the player to decide if they want to load from the latest auto save. If they do not they can load from one of their manual saves. 

### [F1.d] The player must be able to undo every major choice (all the way back to the start of play), even from a saved game. They should be able to redo (undo of undo operations) multiple times.
Because we save after every turn, we automatically are able to undo every major choice based on the latest change. We are also able to redo an undo using a seperate redo stack in order to keep track of the changes. 

## Reflection
The only mindset change we had coming into this sprint was how we structured our code to better help us in the future. We made sure that functions were really one purpose functions so that debugging was made easier. We did this so that future requirements could be implemented seemlessly and in doing so this made it easier to explain our code.
