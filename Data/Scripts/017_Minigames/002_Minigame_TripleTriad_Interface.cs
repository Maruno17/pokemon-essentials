using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for Triple Triad cards based on Pokemon species data.
    /// Manages card statistics, visual representation, and battle calculations.
    /// </summary>
    public interface ITriadCard
    {
        /// <summary>
        /// Gets the Pokemon species this card represents.
        /// </summary>
        int species { get; }

        /// <summary>
        /// Gets the form number of the Pokemon species.
        /// </summary>
        int form { get; }

        /// <summary>
        /// Gets the north directional attack value.
        /// </summary>
        int north { get; }

        /// <summary>
        /// Gets the east directional attack value.
        /// </summary>
        int east { get; }

        /// <summary>
        /// Gets the south directional attack value.
        /// </summary>
        int south { get; }

        /// <summary>
        /// Gets the west directional attack value.
        /// </summary>
        int west { get; }

        /// <summary>
        /// Gets the primary type of this card for effectiveness calculations.
        /// </summary>
        int type { get; }

        /// <summary>
        /// Converts base stat values to card values using predefined thresholds.
        /// </summary>
        /// <param name="stat">The base stat value to convert</param>
        /// <returns>Card value from 1-10</returns>
        int baseStatToValue(int stat);

        /// <summary>
        /// Gets the attack value for a specific directional panel.
        /// </summary>
        /// <param name="panel">Panel direction (0=west, 1=east, 2=north, 3=south)</param>
        /// <returns>Attack value for the specified direction</returns>
        int attack(int panel);

        /// <summary>
        /// Gets the defense value for a specific directional panel.
        /// </summary>
        /// <param name="panel">Panel direction (0=west, 1=east, 2=north, 3=south)</param>
        /// <returns>Defense value for the specified direction</returns>
        int defense(int panel);

        /// <summary>
        /// Calculates type effectiveness bonus against an opponent card.
        /// </summary>
        /// <param name="opponent">The opposing card</param>
        /// <returns>Bonus modifier (-2 to +1)</returns>
        int bonus(ITriadCard opponent);

        /// <summary>
        /// Calculates the purchase price of this card based on stats.
        /// </summary>
        /// <returns>Price in currency units</returns>
        int price();

        /// <summary>
        /// Creates a bitmap representation of the card for the specified owner.
        /// </summary>
        /// <param name="owner">Owner type (0=back, 1=player, 2=opponent)</param>
        /// <returns>Bitmap of the card</returns>
        object createBitmap(int owner);
    }

    /// <summary>
    /// Interface for game board squares in Triple Triad.
    /// Manages card ownership, special tile types, and battle calculations.
    /// </summary>
    public interface ITriadSquare
    {
        /// <summary>
        /// Gets or sets the owner of this square (0=empty, 1=player, 2=opponent).
        /// </summary>
        int owner { get; set; }

        /// <summary>
        /// Gets or sets the card placed on this square.
        /// </summary>
        ITriadCard card { get; set; }

        /// <summary>
        /// Gets or sets the elemental type of this square for special rules.
        /// </summary>
        int type { get; set; }

        /// <summary>
        /// Gets the attack value for a specific directional panel from the card.
        /// </summary>
        /// <param name="panel">Panel direction</param>
        /// <returns>Attack value</returns>
        int attack(int panel);

        /// <summary>
        /// Calculates type effectiveness bonus against another square's card.
        /// </summary>
        /// <param name="square">The opposing square</param>
        /// <returns>Bonus modifier</returns>
        int bonus(ITriadSquare square);

        /// <summary>
        /// Gets the defense value for a specific directional panel from the card.
        /// </summary>
        /// <param name="panel">Panel direction</param>
        /// <returns>Defense value</returns>
        int defense(int panel);
    }

    /// <summary>
    /// Interface for the Triple Triad game scene and visual management.
    /// Handles all rendering, animations, and user interface elements.
    /// </summary>
    public interface ITriadScene : IHaveUpdate
    {
        /// <summary>
        /// Initializes the game scene with board setup and sprite creation.
        /// </summary>
        /// <param name="battle">The battle screen controller</param>
        void StartScene(ITriadScreen battle);

        /// <summary>
        /// Cleans up and disposes of all scene resources.
        /// </summary>
        void EndScene();

        /// <summary>
        /// Displays a message for a specified duration.
        /// </summary>
        /// <param name="text">Message to display</param>
        void Display(string text);

        /// <summary>
        /// Displays a message that waits for player input to continue.
        /// </summary>
        /// <param name="text">Message to display</param>
        void DisplayPaused(string text);

        /// <summary>
        /// Sets references to player and opponent card collections.
        /// </summary>
        /// <param name="playerCards">Player's card collection</param>
        /// <param name="opponentCards">Opponent's card collection</param>
        void NotifyCards(IList<object> playerCards, IList<object> opponentCards);

        /// <summary>
        /// Allows player to choose cards from their collection for the duel.
        /// </summary>
        /// <param name="cardStorage">Available cards with quantities</param>
        /// <returns>Array of chosen card species</returns>
        IList<object> ChooseTriadCard(IList<object[]> cardStorage);

        /// <summary>
        /// Displays player's selected cards on the game board.
        /// </summary>
        /// <param name="cards">Array of card species</param>
        void ShowPlayerCards(IList<object> cards);

        /// <summary>
        /// Displays opponent's cards, hidden or revealed based on rules.
        /// </summary>
        /// <param name="cards">Array of card species</param>
        void ShowOpponentCards(IList<object> cards);

        /// <summary>
        /// Allows player to examine opponent's cards if open hand rule is active.
        /// </summary>
        /// <param name="numCards">Number of cards to display</param>
        /// <returns>Selected card index or -1 if cancelled</returns>
        int ViewOpponentCards(int numCards);

        /// <summary>
        /// Handles player card selection during their turn.
        /// </summary>
        /// <param name="numCards">Number of available cards</param>
        /// <returns>Index of selected card</returns>
        int PlayerChooseCard(int numCards);

        /// <summary>
        /// Handles placement of selected card on the game board.
        /// </summary>
        /// <param name="cardIndex">Index of card being placed</param>
        /// <returns>Board position [x, y] or null if cancelled</returns>
        int[] PlayerPlaceCard(int cardIndex);

        /// <summary>
        /// Finalizes player card placement and updates game state.
        /// </summary>
        /// <param name="position">Board position where card was placed</param>
        /// <param name="cardIndex">Index of placed card</param>
        void EndPlaceCard(int[] position, int cardIndex);

        /// <summary>
        /// Displays opponent placing their card with animation.
        /// </summary>
        /// <param name="triadCard">The card being placed</param>
        /// <param name="position">Board position</param>
        /// <param name="cardIndex">Card index</param>
        void OpponentPlaceCard(ITriadCard triadCard, int[] position, int cardIndex);

        /// <summary>
        /// Finalizes opponent card placement and updates game state.
        /// </summary>
        /// <param name="position">Board position where card was placed</param>
        /// <param name="cardIndex">Index of placed card</param>
        void EndOpponentPlaceCard(int[] position, int cardIndex);

        /// <summary>
        /// Refreshes card displays to show current ownership colors.
        /// </summary>
        void Refresh();

        /// <summary>
        /// Updates the score display showing cards controlled by each player.
        /// </summary>
        void UpdateScore();

        /// <summary>
        /// Updates sprite animations and display elements.
        /// </summary>
        void Update();
    }

    /// <summary>
    /// Interface for the main Triple Triad game logic and rule management.
    /// Controls game flow, AI decisions, win conditions, and card trading.
    /// </summary>
    public interface ITriadScreen
    {
        /// <summary>
        /// Gets or sets whether opponent cards are visible to the player.
        /// </summary>
        bool openHand { get; set; }

        /// <summary>
        /// Gets or sets whether unplayed cards count toward final score.
        /// </summary>
        bool countUnplayedCards { get; set; }

        /// <summary>
        /// Gets the width of the game board.
        /// </summary>
        int width { get; }

        /// <summary>
        /// Gets the height of the game board.
        /// </summary>
        int height { get; }

        /// <summary>
        /// Gets the array of board squares.
        /// </summary>
        ITriadSquare[] board { get; }

        /// <summary>
        /// Gets the player's display name.
        /// </summary>
        string playerName { get; }

        /// <summary>
        /// Gets the opponent's display name.
        /// </summary>
        string opponentName { get; }

        /// <summary>
        /// Calculates the maximum number of cards each player uses.
        /// </summary>
        /// <returns>Number of cards per player</returns>
        int maxCards();

        /// <summary>
        /// Checks if a board position is occupied by a card.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <returns>True if occupied</returns>
        bool isOccupied(int x, int y);

        /// <summary>
        /// Gets the owner of a specific board position.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <returns>Owner ID (0=empty, 1=player, 2=opponent)</returns>
        int getOwner(int x, int y);

        /// <summary>
        /// Gets the square object at a specific board position.
        /// </summary>
        /// <param name="x">X coordinate</param>
        /// <param name="y">Y coordinate</param>
        /// <returns>The square at the position</returns>
        ITriadSquare getPanel(int x, int y);

        /// <summary>
        /// Gets the quantity of a specific item in a collection.
        /// </summary>
        /// <param name="items">Item collection</param>
        /// <param name="item">Item to count</param>
        /// <returns>Quantity of the item</returns>
        int quantity(IList<object[]> items, object item);

        /// <summary>
        /// Adds an item to a collection with quantity limits.
        /// </summary>
        /// <param name="items">Target collection</param>
        /// <param name="item">Item to add</param>
        /// <returns>True if successfully added</returns>
        bool Add(IList<object[]> items, object item);

        /// <summary>
        /// Removes an item from a collection.
        /// </summary>
        /// <param name="items">Source collection</param>
        /// <param name="item">Item to remove</param>
        /// <returns>True if successfully removed</returns>
        bool Subtract(IList<object[]> items, object item);

        /// <summary>
        /// Calculates card flips when a card is placed, including combo chains.
        /// </summary>
        /// <param name="x">X position of placed card</param>
        /// <param name="y">Y position of placed card</param>
        /// <param name="attackerParam">Optional attacker override for combos</param>
        /// <param name="recurse">Whether this is a recursive combo call</param>
        /// <returns>Array of flipped positions</returns>
        int[][] flipBoard(int x, int y, ITriadSquare attackerParam = null, bool recurse = false);

        /// <summary>
        /// Starts a complete Triple Triad game with specified parameters.
        /// </summary>
        /// <param name="opponentName">Name of the opponent</param>
        /// <param name="minLevel">Minimum level for AI card selection</param>
        /// <param name="maxLevel">Maximum level for AI card selection</param>
        /// <param name="rules">Array of special rules to apply</param>
        /// <param name="oppdeck">Predefined opponent deck (optional)</param>
        /// <param name="prize">Specific prize card for winning (optional)</param>
        /// <returns>Game result (0=error, 1=player win, 2=player loss, 3=draw)</returns>
        int StartScreen(string opponentName, int minLevel, int maxLevel, string[] rules = null, object[] oppdeck = null, object prize = null);
    }

    /// <summary>
    /// Interface for Triple Triad card storage and management.
    /// Handles player's card collection with quantity limits and operations.
    /// </summary>
    public interface ITriadStorage
    {
        /// <summary>
        /// Gets the items collection as array of [species, quantity] pairs.
        /// </summary>
        object[][] items { get; }

        /// <summary>
        /// Gets the number of different card types in storage.
        /// </summary>
        int length { get; }

        /// <summary>
        /// Checks if the storage is empty.
        /// </summary>
        /// <returns>True if no cards are stored</returns>
        bool empty();

        /// <summary>
        /// Gets the maximum storage capacity.
        /// </summary>
        /// <returns>Maximum number of different card types</returns>
        int maxSize();

        /// <summary>
        /// Removes all cards from storage.
        /// </summary>
        void clear();

        /// <summary>
        /// Gets the card species at a specific index.
        /// </summary>
        /// <param name="index">Index in storage</param>
        /// <returns>Card species or null if invalid index</returns>
        object get_item(int index);

        /// <summary>
        /// Gets the quantity of cards at a specific index.
        /// </summary>
        /// <param name="index">Index in storage</param>
        /// <returns>Quantity of cards</returns>
        int get_item_count(int index);

        /// <summary>
        /// Gets the total quantity of a specific card type.
        /// </summary>
        /// <param name="item">Card species</param>
        /// <returns>Total quantity owned</returns>
        int quantity(object item);

        /// <summary>
        /// Checks if cards can be added without exceeding limits.
        /// </summary>
        /// <param name="item">Card species</param>
        /// <param name="qty">Quantity to add</param>
        /// <returns>True if addition is possible</returns>
        bool can_add(object item, int qty = 1);

        /// <summary>
        /// Adds cards to the storage.
        /// </summary>
        /// <param name="item">Card species</param>
        /// <param name="qty">Quantity to add</param>
        /// <returns>True if successfully added</returns>
        bool add(object item, int qty = 1);

        /// <summary>
        /// Removes cards from the storage.
        /// </summary>
        /// <param name="item">Card species</param>
        /// <param name="qty">Quantity to remove</param>
        /// <returns>True if successfully removed</returns>
        bool remove(object item, int qty = 1);

        /// <summary>
        /// Calculates the total number of individual cards.
        /// </summary>
        /// <returns>Sum of all card quantities</returns>
        int total_cards();
    }

    /// <summary>
    /// Interface for global Triple Triad functions and card management.
    /// Provides utility functions for checking duel availability and managing cards.
    /// </summary>
    public interface ITriadManager
    {
        /// <summary>
        /// Checks if the player has enough cards to participate in a duel.
        /// </summary>
        /// <returns>True if player can duel</returns>
        bool CanTriadDuel();

        /// <summary>
        /// Starts a Triple Triad duel with the specified parameters.
        /// </summary>
        /// <param name="name">Opponent name</param>
        /// <param name="minLevel">Minimum opponent level</param>
        /// <param name="maxLevel">Maximum opponent level</param>
        /// <param name="rules">Special rules array</param>
        /// <param name="oppdeck">Predefined opponent deck</param>
        /// <param name="prize">Special prize card</param>
        /// <returns>Game result</returns>
        int TriadDuel(string name, int minLevel, int maxLevel, string[] rules = null, object[] oppdeck = null, object prize = null);

        /// <summary>
        /// Opens the card purchase shop interface.
        /// </summary>
        void BuyTriads();

        /// <summary>
        /// Opens the card selling shop interface.
        /// </summary>
        void SellTriads();

        /// <summary>
        /// Displays the player's card collection.
        /// </summary>
        void TriadList();

        /// <summary>
        /// Gives a specific card to the player.
        /// </summary>
        /// <param name="species">Card species to give</param>
        /// <param name="quantity">Number of cards to give</param>
        /// <returns>True if successfully given</returns>
        bool GiveTriadCard(object species, int quantity = 1);
    }
}