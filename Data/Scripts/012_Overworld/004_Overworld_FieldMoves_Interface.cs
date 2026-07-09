using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Hidden move handlers.
	/// </summary>
	/// <remarks>
	/// Interface for hidden move handlers module.
	/// </remarks>
	public interface IHiddenMoveHandlers
	{
		/// <summary>
		/// Gets the CanUseMove handler hash.
		/// </summary>
		IMoveHandlerHash CanUseMove { get; }

		/// <summary>
		/// Gets the ConfirmUseMove handler hash.
		/// </summary>
		IMoveHandlerHash ConfirmUseMove { get; }

		/// <summary>
		/// Gets the UseMove handler hash.
		/// </summary>
		IMoveHandlerHash UseMove { get; }

		/// <summary>
		/// Adds a handler for checking if a move can be used.
		/// </summary>
		/// <param name="item">The move or item identifier</param>
		/// <param name="proc">The handler procedure</param>
		void addCanUseMove(int item, object proc);

		/// <summary>
		/// Adds a handler for confirming move usage.
		/// </summary>
		/// <param name="item">The move or item identifier</param>
		/// <param name="proc">The handler procedure</param>
		void addConfirmUseMove(int item, object proc);

		/// <summary>
		/// Adds a handler for using a move.
		/// </summary>
		/// <param name="item">The move or item identifier</param>
		/// <param name="proc">The handler procedure</param>
		void addUseMove(int item, object proc);

		/// <summary>
		/// Checks if the item has all necessary handlers.
		/// </summary>
		/// <param name="item">The move or item identifier</param>
		/// <returns>True if both CanUseMove and UseMove handlers exist</returns>
		bool hasHandler(int item);

		/// <summary>
		/// Triggers the CanUseMove handler for an item.
		/// </summary>
		/// <param name="item">The move or item identifier</param>
		/// <param name="pokemon">The Pokémon using the move</param>
		/// <param name="showmsg">Whether to show messages</param>
		/// <returns>True if the move can be used</returns>
		bool triggerCanUseMove(int item, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// Triggers the ConfirmUseMove handler for an item.
		/// </summary>
		/// <param name="item">The move or item identifier</param>
		/// <param name="pokemon">The Pokémon using the move</param>
		/// <returns>True if the player confirmed they want to use the move</returns>
		bool triggerConfirmUseMove(int item, IPokemon pokemon);

		/// <summary>
		/// Triggers the UseMove handler for an item.
		/// </summary>
		/// <param name="item">The move or item identifier</param>
		/// <param name="pokemon">The Pokémon using the move</param>
		/// <returns>True if the move was successfully used</returns>
		bool triggerUseMove(int item, IPokemon pokemon);
	}

	/// <summary>
	/// Interface for hidden move utility functions.
	/// </summary>
	public interface IMainOverworldHiddenMoveUtils : IMain
	{
		/// <summary>
		/// Checks if a Pokémon can use a hidden move.
		/// </summary>
		/// <param name="pkmn">The Pokémon to check</param>
		/// <param name="move">The move to check</param>
		/// <param name="showmsg">Whether to show messages</param>
		/// <returns>True if the move can be used</returns>
		bool CanUseHiddenMove(IPokemon pkmn, object move, bool showmsg = true);

		/// <summary>
		/// Confirms the use of a hidden move with the player.
		/// </summary>
		/// <param name="pokemon">The Pokémon using the move</param>
		/// <param name="move">The move to use</param>
		/// <returns>True if the player confirmed</returns>
		bool ConfirmUseHiddenMove(IPokemon pokemon, object move);

		/// <summary>
		/// Uses a hidden move.
		/// </summary>
		/// <param name="pokemon">The Pokémon using the move</param>
		/// <param name="move">The move to use</param>
		/// <returns>True if the move was successfully used</returns>
		bool UseHiddenMove(IPokemon pokemon, object move);

		/// <summary>
		/// Triggers hidden move event handlers.
		/// </summary>
		[System.Obsolete("Unused")]
		void HiddenMoveEvent();

		/// <summary>
		/// Checks if the player has the required badge for a hidden move.
		/// </summary>
		/// <param name="badge">The badge requirement (-1 for no requirement)</param>
		/// <param name="showmsg">Whether to show messages</param>
		/// <returns>True if the badge requirement is met</returns>
		bool CheckHiddenMoveBadge(int badge = -1, bool showmsg = true);
	//}

	/// <summary>
	/// Interface for hidden move animation functions.
	/// </summary>
	//public interface IHiddenMoveAnimation
	//{
		/// <summary>
		/// Plays the hidden move animation for a Pokémon.
		/// </summary>
		/// <param name="pokemon">The Pokémon using the move</param>
		/// <returns>True if the animation was played</returns>
		bool HiddenMoveAnimation(IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Cut move functionality.
	/// </summary>
	//public interface ICutMove
	//{
		/// <summary>
		/// Cut.
		/// </summary>
		/// <remarks>
		/// Attempts to use Cut on a tree.
		/// </remarks>
		/// <returns>True if Cut was successfully used</returns>
		bool Cut();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:CUT, proc { |move, pkmn, showmsg|
		///   next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_CUT, showmsg)
		///   facingEvent = $game_player.pbFacingEvent
		///   if !facingEvent || !facingEvent.name[/cuttree/i]
		///     pbMessage(_INTL("You can't use that here.")) if showmsg
		///     next false
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Cut(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:CUT, proc { |move, pokemon|
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///   end
		///   $stats.cut_count += 1
		///   facingEvent = $game_player.pbFacingEvent
		///   pbSmashEvent(facingEvent) if facingEvent
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Cut(int move, IPokemon pokemon);

		/// <summary>
		/// Smashes an event (tree or rock).
		/// </summary>
		/// <param name="evt">The event to smash</param>
		void SmashEvent(IGameEvent evt);
	//}

	/// <summary>
	/// Interface for Dig move functionality.
	/// </summary>
	//public interface IDigMove
	//{
		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:DIG, proc { |move, pkmn, showmsg|
		///   escape = ($PokemonGlobal.escapePoint rescue nil)
		///   if !escape || escape == []
		///     pbMessage(_INTL("You can't use that here.")) if showmsg
		///     next false
		///   end
		///   if !$game_player.can_map_transfer_with_follower?
		///     pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
		///     next false
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Dig(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::ConfirmUseMove.add(:DIG, proc { |move, pkmn|
		///   escape = ($PokemonGlobal.escapePoint rescue nil)
		///   next false if !escape || escape == []
		///   mapname = pbGetMapNameFromId(escape[0])
		///   next pbConfirmMessage(_INTL("Want to escape from here and return to {1}?", mapname))
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_ConfirmUseMove_Dig(int move, IPokemon pokemon);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:DIG, proc { |move, pokemon|
		///   escape = ($PokemonGlobal.escapePoint rescue nil)
		///   if escape
		///     if !pbHiddenMoveAnimation(pokemon)
		///       pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///     end
		///     pbFadeOutIn do
		///       $game_temp.player_new_map_id    = escape[0]
		///       $game_temp.player_new_x         = escape[1]
		///       $game_temp.player_new_y         = escape[2]
		///       $game_temp.player_new_direction = escape[3]
		///       pbDismountBike
		///       $scene.transfer_player
		///       $game_map.autoplay
		///       $game_map.refresh
		///     end
		///     pbEraseEscapePoint
		///     next true
		///   end
		///   next false
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Dig(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Dive move functionality.
	/// </summary>
	//public interface IDiveMove
	//{
		/// <summary>
		/// Attempts to dive underwater.
		/// </summary>
		/// <returns>True if diving was successful</returns>
		bool Dive();

		/// <summary>
		/// Attempts to surface from underwater.
		/// </summary>
		/// <returns>True if surfacing was successful</returns>
		bool Surfacing();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_player_interact, :diving,
		///   proc {
		///     if $PokemonGlobal.diving
		///       surface_map_id = nil
		///       GameData::MapMetadata.each do |map_data|
		///         next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
		///         surface_map_id = map_data.id
		///         break
		///       end
		///       if surface_map_id &&
		///          $map_factory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
		///         pbSurfacing
		///       end
		///     elsif $game_player.terrain_tag.can_dive
		///       pbDive
		///     end
		///   }
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnAction"/>
		bool OnPlayerInteractTrigger_diving();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:DIVE, proc { |move, pkmn, showmsg|
		///   next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_DIVE, showmsg)
		///   if $PokemonGlobal.diving
		///     surface_map_id = nil
		///     GameData::MapMetadata.each do |map_data|
		///       next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
		///       surface_map_id = map_data.id
		///       break
		///     end
		///     if !surface_map_id ||
		///        !$map_factory.getTerrainTag(surface_map_id, $game_player.x, $game_player.y).can_dive
		///       pbMessage(_INTL("You can't use that here.")) if showmsg
		///       next false
		///     end
		///   else
		///     if !$game_map.metadata&.dive_map_id
		///       pbMessage(_INTL("You can't use that here.")) if showmsg
		///       next false
		///     end
		///     if !$game_player.terrain_tag.can_dive
		///       pbMessage(_INTL("You can't use that here.")) if showmsg
		///       next false
		///     end
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Dive(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:DIVE, proc { |move, pokemon|
		///   wasdiving = $PokemonGlobal.diving
		///   if $PokemonGlobal.diving
		///     dive_map_id = nil
		///     GameData::MapMetadata.each do |map_data|
		///       next if !map_data.dive_map_id || map_data.dive_map_id != $game_map.map_id
		///       dive_map_id = map_data.id
		///       break
		///     end
		///   else
		///     dive_map_id = $game_map.metadata&.dive_map_id
		///   end
		///   next false if !dive_map_id
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///   end
		///   pbFadeOutIn do
		///     $game_temp.player_new_map_id    = dive_map_id
		///     $game_temp.player_new_x         = $game_player.x
		///     $game_temp.player_new_y         = $game_player.y
		///     $game_temp.player_new_direction = $game_player.direction
		///     $PokemonGlobal.surfing = wasdiving
		///     $PokemonGlobal.diving  = !wasdiving
		///     pbUpdateVehicle
		///     $scene.transfer_player(false)
		///     $game_map.autoplay
		///     $game_map.refresh
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Dive(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Flash move functionality.
	/// </summary>
	//public interface IFlashMove
	//{
		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:FLASH, proc { |move, pkmn, showmsg|
		///   next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_FLASH, showmsg)
		///   if !$game_map.metadata&.dark_map
		///     pbMessage(_INTL("You can't use that here.")) if showmsg
		///     next false
		///   end
		///   if $PokemonGlobal.flashUsed
		///     pbMessage(_INTL("Flash is already being used.")) if showmsg
		///     next false
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Flash(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:FLASH, proc { |move, pokemon|
		///   darkness = $game_temp.darkness_sprite
		///   next false if !darkness || darkness.disposed?
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///   end
		///   $PokemonGlobal.flashUsed = true
		///   $stats.flash_count += 1
		///   duration = 0.7
		///   pbWait(duration) do |delta_t|
		///     darkness.radius = lerp(darkness.radiusMin, darkness.radiusMax, duration, delta_t)
		///   end
		///   darkness.radius = darkness.radiusMax
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Flash(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Fly move functionality.
	/// </summary>
	//public interface IFlyMove
	//{
		/// <summary>
		/// Checks if the player can use Fly.
		/// </summary>
		/// <param name="pkmn">The Pokémon to check</param>
		/// <param name="show_messages">Whether to show messages</param>
		/// <returns>True if Fly can be used</returns>
		bool CanFly(IPokemon pkmn = null, bool show_messages = false);

		/// <summary>
		/// Flies to a new location.
		/// </summary>
		/// <param name="pkmn">The Pokémon using Fly</param>
		/// <param name="move">The move being used</param>
		/// <returns>True if the flight was successful</returns>
		bool FlyToNewLocation(IPokemon pkmn = null, int move = 0); //int move = Moves.FLY

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:FLY, proc { |move, pkmn, showmsg|
		///   next pbCanFly?(pkmn, showmsg)
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Fly(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:FLY, proc { |move, pkmn|
		///   if $game_temp.fly_destination.nil?
		///     pbMessage(_INTL("You can't use that here."))
		///     next false
		///   end
		///   pbFlyToNewLocation(pkmn)
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Fly(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Headbutt move functionality.
	/// </summary>
	//public interface IHeadbuttMove
	//{
		/// <summary>
		/// Performs the Headbutt effect on a tree.
		/// </summary>
		/// <param name="evt">The event (tree) to headbutt</param>
		void HeadbuttEffect(IGameEvent evt = null);

		/// <summary>
		/// Attempts to use Headbutt on a tree.
		/// </summary>
		/// <param name="evt">The event (tree) to headbutt</param>
		/// <returns>True if Headbutt was successfully used</returns>
		bool Headbutt(IGameEvent evt = null);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:HEADBUTT, proc { |move, pkmn, showmsg|
		///   facingEvent = $game_player.pbFacingEvent
		///   if !facingEvent || !facingEvent.name[/headbutttree/i]
		///     pbMessage(_INTL("You can't use that here.")) if showmsg
		///     next false
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Headbutt(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:HEADBUTT, proc { |move, pokemon|
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///   end
		///   $stats.headbutt_count += 1
		///   facingEvent = $game_player.pbFacingEvent
		///   pbHeadbuttEffect(facingEvent)
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Headbutt(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Rock Smash move functionality.
	/// </summary>
	//public interface IRockSmashMove
	//{
		/// <summary>
		/// Triggers a random encounter from Rock Smash.
		/// </summary>
		void RockSmashRandomEncounter();

		/// <summary>
		/// Attempts to use Rock Smash on a rock.
		/// </summary>
		/// <returns>True if Rock Smash was successfully used</returns>
		bool RockSmash();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:ROCKSMASH, proc { |move, pkmn, showmsg|
		///   next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH, showmsg)
		///   facingEvent = $game_player.pbFacingEvent
		///   if !facingEvent || !facingEvent.name[/smashrock/i]
		///     pbMessage(_INTL("You can't use that here.")) if showmsg
		///     next false
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_RockSmash(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:ROCKSMASH, proc { |move, pokemon|
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///   end
		///   $stats.rock_smash_count += 1
		///   facingEvent = $game_player.pbFacingEvent
		///   if facingEvent
		///     pbSmashEvent(facingEvent)
		///     pbRockSmashRandomEncounter
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_RockSmash(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Strength move functionality.
	/// </summary>
	//public interface IStrengthMove
	//{
		/// <summary>
		/// Attempts to use Strength to move boulders.
		/// </summary>
		/// <returns>True if Strength was successfully used</returns>
		bool Strength();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_player_interact, :strength_event,
		///   proc {
		///     facingEvent = $game_player.pbFacingEvent
		///     pbStrength if facingEvent && facingEvent.name[/strengthboulder/i]
		///   }
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnAction"/>
		bool OnPlayerInteractTrigger_strength_event();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:STRENGTH, proc { |move, pkmn, showmsg|
		///   next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_STRENGTH, showmsg)
		///   if $PokemonMap.strengthUsed
		///     pbMessage(_INTL("Strength is already being used.")) if showmsg
		///     next false
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Strength(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:STRENGTH, proc { |move, pokemon|
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name) + "\1")
		///   end
		///   pbMessage(_INTL("Strength made it possible to move boulders around!"))
		///   $PokemonMap.strengthUsed = true
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Strength(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Surf move functionality.
	/// </summary>
	//public interface ISurfMove
	//{
		/// <summary>
		/// Attempts to start surfing on water.
		/// </summary>
		/// <returns>True if surfing was started</returns>
		bool Surf();

		/// <summary>
		/// Starts the surfing state.
		/// </summary>
		void StartSurfing();

		/// <summary>
		/// Attempts to end surfing.
		/// </summary>
		/// <param name="xOffset">X offset for ending position</param>
		/// <param name="yOffset">Y offset for ending position</param>
		/// <returns>True if surfing was ended</returns>
		bool EndSurf(int xOffset, int yOffset);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_player_interact, :start_surfing,
		///   proc {
		///     next if $PokemonGlobal.surfing
		///     next if $game_map.metadata&.always_bicycle
		///     next if !$game_player.pbFacingTerrainTag.can_surf_freely
		///     next if !$game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
		///     pbSurf
		///   }
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnAction"/>
		bool OnPlayerInteractTrigger_start_surfing(int move, IPokemon pokemon);

		/// <summary>
		/// Do things after a jump to start/end surfing.
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_step_taken, :surf_jump,
		///   proc { |event|
		///     next if !$scene.is_a?(Scene_Map) || !event.is_a?(Game_Player)
		///     next if !$game_temp.surf_base_coords
		///     # Hide the temporary surf base graphic after jumping onto/off it
		///     $game_temp.surf_base_coords = nil
		///     # Finish up dismounting from surfing
		///     if $game_temp.ending_surf
		///       pbCancelVehicles
		///       $PokemonEncounters.reset_step_count
		///       $game_map.autoplayAsCue   # Play regular map BGM
		///       $game_temp.ending_surf = false
		///     end
		///   }
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnStepTaken"/>
		bool OnStepTakenTrigger_surf_jump(int move, IPokemon pokemon);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:SURF, proc { |move, pkmn, showmsg|
		///   next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_SURF, showmsg)
		///   if $PokemonGlobal.surfing
		///     pbMessage(_INTL("You're already surfing.")) if showmsg
		///     next false
		///   end
		///   if !$game_player.can_ride_vehicle_with_follower?
		///     pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
		///     next false
		///   end
		///   if $game_map.metadata&.always_bicycle
		///     pbMessage(_INTL("Let's enjoy cycling!")) if showmsg
		///     next false
		///   end
		///   if !$game_player.pbFacingTerrainTag.can_surf_freely ||
		///      !$game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
		///     pbMessage(_INTL("No surfing here!")) if showmsg
		///     next false
		///   end
		///   next true
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Surf(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:SURF, proc { |move, pokemon|
		///   $game_temp.in_menu = false
		///   pbCancelVehicles
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///   end
		///   surfbgm = GameData::Metadata.get.surf_BGM
		///   pbCueBGM(surfbgm, 0.5) if surfbgm
		///   pbStartSurfing
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Surf(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Sweet Scent move functionality.
	/// </summary>
	//public interface ISweetScentMove
	//{
		/// <summary>
		/// Uses Sweet Scent to attract wild Pokémon.
		/// </summary>
		void SweetScent();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:SWEETSCENT, proc { |move, pkmn, showmsg|
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Sweetscent(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:SWEETSCENT, proc { |move, pokemon|
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///   end
		///   pbSweetScent
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Sweetscent(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Waterfall move functionality.
	/// </summary>
	//public interface IWaterfallMove
	//{

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:TELEPORT, proc { |move, pkmn, showmsg|
		///   if !$game_map.metadata&.outdoor_map
		///     pbMessage(_INTL("You can't use that here.")) if showmsg
		///     next false
		///   end
		///   healing = $PokemonGlobal.healingSpot
		///   healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
		///   healing = GameData::Metadata.get.home if !healing   # Home
		///   if !healing
		///     pbMessage(_INTL("You can't use that here.")) if showmsg
		///     next false
		///   end
		///   if !$game_player.can_map_transfer_with_follower?
		///     pbMessage(_INTL("It can't be used when you have someone with you.")) if showmsg
		///     next false
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Teleport(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::ConfirmUseMove.add(:TELEPORT, proc { |move, pkmn|
		///   healing = $PokemonGlobal.healingSpot
		///   healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
		///   healing = GameData::Metadata.get.home if !healing   # Home
		///   next false if !healing
		///   mapname = pbGetMapNameFromId(healing[0])
		///   next pbConfirmMessage(_INTL("Want to return to the healing spot used last in {1}?", mapname))
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_ConfirmUseMove_Teleport(int move, IPokemon pokemon);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:TELEPORT, proc { |move, pokemon|
		///   healing = $PokemonGlobal.healingSpot
		///   healing = GameData::PlayerMetadata.get($player.character_ID)&.home if !healing
		///   healing = GameData::Metadata.get.home if !healing   # Home
		///   next false if !healing
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///   end
		///   pbFadeOutIn do
		///     $game_temp.player_new_map_id    = healing[0]
		///     $game_temp.player_new_x         = healing[1]
		///     $game_temp.player_new_y         = healing[2]
		///     $game_temp.player_new_direction = 2
		///     pbDismountBike
		///     $scene.transfer_player
		///     $game_map.autoplay
		///     $game_map.refresh
		///   end
		///   pbEraseEscapePoint
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Teleport(int move, IPokemon pokemon);
	//}

	/// <summary>
	/// Interface for Waterfall move functionality.
	/// </summary>
	//public interface IWaterfallMove
	//{
		/// <summary>
		/// Starts ascending a waterfall.
		/// </summary>
		void AscendWaterfall();

		/// <summary>
		/// Handles traversing (ascending/descending) a waterfall.
		/// </summary>
		/// <remarks>
		/// Triggers after finishing each step while ascending/descending a waterfall.
		/// </remarks>
		void TraverseWaterfall();

		/// <summary>
		/// Attempts to use Waterfall to climb up.
		/// </summary>
		/// <returns>True if Waterfall was successfully used</returns>
		bool Waterfall();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// EventHandlers.add(:on_player_interact, :waterfall,
		///   proc {
		///     terrain = $game_player.pbFacingTerrainTag
		///     if terrain.waterfall
		///       pbWaterfall
		///     elsif terrain.waterfall_crest
		///       pbMessage(_INTL("A wall of water is crashing down with a mighty roar."))
		///     end
		///   }
		/// )
		/// </code>
		/// </example>
		/// <seealso cref="IEvents.OnAction"/>
		bool OnPlayerInteractTrigger_waterfall();

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::CanUseMove.add(:WATERFALL, proc { |move, pkmn, showmsg|
		///   next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_WATERFALL, showmsg)
		///   if !$game_player.pbFacingTerrainTag.waterfall
		///     pbMessage(_INTL("You can't use that here.")) if showmsg
		///     next false
		///   end
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_CanUseMove_Waterfall(int move, IPokemon pokemon, bool showmsg);

		/// <summary>
		/// </summary>
		/// <example>
		/// <code>
		/// HiddenMoveHandlers::UseMove.add(:WATERFALL, proc { |move, pokemon|
		///   if !pbHiddenMoveAnimation(pokemon)
		///     pbMessage(_INTL("{1} used {2}!", pokemon.name, GameData::Move.get(move).name))
		///   end
		///   pbAscendWaterfall
		///   next true
		/// })
		/// </code>
		/// </example>
		bool HiddenMoveHandlers_UseMove_Waterfall(int move, IPokemon pokemon);
	}
}