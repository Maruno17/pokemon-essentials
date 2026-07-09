using System;

namespace PokemonEssentials
{
    /// <summary>
    /// Represents a planted berry. Stored in <see cref="IGlobalMetadata.eventvars"/>.
    /// </summary>
    /// <remarks>
    /// Interface representing a planted berry stored in global event variables.
    /// </remarks>
    /// <seealso cref="IGameManager.pokemonGlobal"/>
    /// <seealso cref="IGlobalMetadata.eventvars"/>
    public interface IBerryPlantData : IHaveUpdate
    {
        /// <summary>
        /// Gets or sets whether to use new mechanics (false for Gen 3, true for Gen 4).
        /// </summary>
        bool new_mechanics { get; set; }

        /// <summary>
        /// Gets or sets the ID of the berry that was planted.
        /// </summary>
        int berry_id { get; set; }

        /// <summary>
        /// Gets or sets the ID of the mulch applied (Gen 4 mechanics).
        /// </summary>
        int mulch_id { get; set; }

        /// <summary>
        /// Gets or sets how long the plant has been alive.
        /// </summary>
        int time_alive { get; set; }

        /// <summary>
        /// Gets or sets when the plant was last updated.
        /// </summary>
        int time_last_updated { get; set; }

        /// <summary>
        /// Gets or sets the current growth stage of the plant.
        /// </summary>
        int growth_stage { get; set; }

        /// <summary>
        /// Gets or sets the number of times this plant has been replanted.
        /// </summary>
        int replant_count { get; set; }

        /// <summary>
        /// Gets or sets whether the plant was watered during the current stage (Gen 3 mechanics).
        /// </summary>
        bool watered_this_stage { get; set; }

        /// <summary>
        /// Gets or sets the total watering count (Gen 3 mechanics).
        /// </summary>
        int watering_count { get; set; }

        /// <summary>
        /// Gets or sets the current moisture level (Gen 4 mechanics).
        /// </summary>
        int moisture_level { get; set; }

        /// <summary>
        /// Gets or sets the yield penalty from lack of water (Gen 4 mechanics).
        /// </summary>
        int yield_penalty { get; set; }

        IBerryPlantData initialize();

		/// <summary>
		/// Resets the berry plant data.
		/// </summary>
		/// <param name="planting">Whether this reset is for planting a new berry</param>
		void reset(bool planting = false);

        /// <summary>
        /// Plants a berry in this location.
        /// </summary>
        /// <param name="berry_id">The ID of the berry to plant</param>
        void plant(int berry_id);

        /// <summary>
        /// Replants the berry (for auto-replanting mechanics).
        /// </summary>
        void replant();

        /// <summary>
        /// Checks if a berry is currently planted.
        /// </summary>
        /// <returns>True if a berry is planted</returns>
        bool planted { get; }

        /// <summary>
        /// Checks if the plant is currently growing.
        /// </summary>
        /// <returns>True if the plant is growing but not fully grown</returns>
        bool growing { get; }

        /// <summary>
        /// Checks if the plant has fully grown and can be harvested.
        /// </summary>
        /// <returns>True if the plant is fully grown</returns>
        bool grown { get; }

        /// <summary>
        /// Checks if the plant has been replanted at least once.
        /// </summary>
        /// <returns>True if the plant has been replanted</returns>
        bool replanted { get; }

        /// <summary>
        /// Gets the current moisture stage for display purposes.
        /// </summary>
        /// <returns>Moisture stage (0=dry, 1=damp, 2=wet)</returns>
        int moisture_stage { get; }

        /// <summary>
        /// Waters the plant.
        /// </summary>
        void water();

        /// <summary>
        /// Calculates the berry yield when harvested.
        /// </summary>
        /// <returns>The number of berries that will be yielded</returns>
        int berry_yield { get; }

        /// <summary>
        /// Updates the plant's growth and condition based on time passed.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for the moisture indicator sprite shown above berry plants.
    /// </summary>
    public interface IBerryPlantMoistureSprite : IHaveUpdate, IDisposable
    {
        IBerryPlantMoistureSprite initialize(IGameEvent evt, IGameMap map, IViewport viewport = null);

        /// <summary>
        /// Disposes of the sprite and its resources.
        /// </summary>
        void dispose();

        /// <summary>
        /// Checks if the sprite has been disposed.
        /// </summary>
        /// <returns>True if disposed</returns>
        bool disposed();

        /// <summary>
        /// Updates the moisture graphic based on plant state.
        /// </summary>
        void update_graphic();

        /// <summary>
        /// Updates the sprite position and moisture state.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for the main berry plant sprite that represents the growing plant.
    /// </summary>
    public interface IBerryPlantSprite : IHaveUpdate, IDisposable
    {
		IBerryPlantSprite initialize(IGameEvent evt, IGameMap map, IViewport viewport);

        /// <summary>
        /// Disposes of the sprite and its resources.
        /// </summary>
        void dispose();

        /// <summary>
        /// Checks if the sprite has been disposed.
        /// </summary>
        /// <returns>True if disposed</returns>
        bool disposed();

        /// <summary>
        /// Sets the event's graphic based on the plant's growth stage.
        /// </summary>
        /// <param name="berry_plant">The berry plant data</param>
        /// <param name="full_check">Whether to force a full check regardless of stage changes</param>
        void set_event_graphic(IBerryPlantData berry_plant, bool full_check = false);

        /// <summary>
        /// Updates the plant's growth state.
        /// </summary>
        /// <param name="berry_plant">The berry plant data</param>
        /// <param name="initial">Whether this is the initial update</param>
        void update_plant(IBerryPlantData berry_plant, bool initial = false);

        /// <summary>
        /// Updates the sprite and plant state.
        /// </summary>
        void update();
    }

    /// <summary>
    /// Interface for berry plant interaction functions.
    /// </summary>
    public interface IMainOverworldBerryPlants : IMain
    {
		/// <summary>
		/// </summary>
		/// <seealso cref="IEvents.OnSpritesetCreate"/>
		/// <seealso cref="EventArg.IOnSpritesetCreateEventArgs"/>
		void OnNewSpritesetMap_add_berry_plant_graphics(ISpritesetMap spriteset, IViewport viewport);

        /// <summary>
        /// Handles interaction with a berry plant event.
        /// </summary>
        void BerryPlant();

        /// <summary>
        /// Handles picking berries from a fully grown plant.
        /// </summary>
        /// <param name="berry">The berry type to pick</param>
        /// <param name="qty">The quantity to pick</param>
        /// <returns>True if berries were successfully picked</returns>
        bool PickBerry(int berry, int qty = 1);
    }
}