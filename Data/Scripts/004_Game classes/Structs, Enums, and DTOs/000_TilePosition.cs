using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Represents tile coordinates including map ID for cross-map references.
	/// </summary>
	//ToDo: Rename to `IMapCoordinates` or `ITileCoordinates`?
	public interface ITilePosition
	{
		int MapId { get; }
		int X { get; }
		int Y { get; }
		int Z { get; }
		int Direction { get; }
		//IVector Vector { get; }
		//Terrains Terrain { get; }

		//TilePosition(int map, float x, float y, float z = 0);
	}

	public struct TilePosition : ITilePosition
	{
		public int MapId { get; }
		public int X { get; }
		public int Y { get; }
		public int Z { get; }
		public int Direction { get; }
		//IVector Vector { get; }
		//Terrains Terrain { get; }

		public TilePosition(int map, int x, int y, int z = 0, int dir = 0)
		{
			MapId = map;
			X = x;
			Y = y;
			Z = z;
			Direction = dir;
		}
	}
}