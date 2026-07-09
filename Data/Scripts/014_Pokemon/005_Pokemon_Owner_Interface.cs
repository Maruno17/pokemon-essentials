using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
	/// <summary>
	/// Stores information about a Pokémon's owner.
	/// </summary>
	public interface IOwner { //ToDo: Rename to `IPokemonOwner`?
		/// <summary>the ID of the owner</summary>
		/// <value>new owner ID</value>
		int id			{ get; set; }
		/// <summary>the name of the owner</summary>
		/// <value>new owner name</value>
		string name		{ get; set; }
		/// <summary>the gender of the owner (0 = male, 1 = female, 2 = unknown)</summary>
		/// <value>new owner gender</value>
		int gender		{ get; set; }
		/// <summary>the language of the owner (see <see cref="GetLanguage"/> for language IDs)</summary>
		/// <value>new owner language</value>
		int language	{ get; set; }

		/// <param name="id">the ID of the owner</param>
		/// <param name="name">the name of the owner</param>
		/// <param name="gender">the gender of the owner (0 = male, 1 = female, 2 = unknown)</param>
		/// <param name="language">the language of the owner (see <see cref="GetLanguage"/> for language IDs)</param>
		IOwner initialize(int id, string name, int gender, int language);

		/// <summary>
		/// Returns a new Owner object populated with values taken from +trainer+.
		/// </summary>
		/// <param name="trainer">trainer object to read data from | Player, NPCTrainer</param>
		// @return [Owner] new Owner object
		//static IOwner new_from_trainer(IPlayer trainer);

		/// <summary>
		/// Returns an Owner object with a foreign ID.
		/// </summary>
		/// <param name="name">owner name</param>
		/// <param name="gender">owner gender</param>
		/// <param name="language">owner language</param>
		// @return [Owner] foreign Owner object
		//static IOwner new_foreign(string name = "", int gender = 2, int language = 2);

		// @param new_id [Integer] new owner ID
		/*int id { set {
			//validate new_id => Integer;
			@id = new_id;
			}
		}

		// @param new_name [String] new owner name
		int name { set {
			//validate new_name => String;
			@name = new_name;
			}
		}

		// @param new_gender [Integer] new owner gender
		int gender { set {
			//validate new_gender => Integer;
			@gender = new_gender;
			}
		}

		// @param new_language [Integer] new owner language
		int language { set {
			//validate new_language => Integer;
			@language = new_language;
			}
		}*/

		/// <summary></summary>
		/// <returns>
		/// the portion of the owner's ID
		/// </returns>
		int public_id();
	}
}