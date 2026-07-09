namespace PokemonEssentials
{
    /// <summary>
    /// Extension interface for <see cref="IBattleAI"/> containing Mega Evolution decision logic.
    /// </summary>
    public interface IBattleAIMegaEvolveLogic : IBattleAI
    {
        /// <summary>
        /// Decide whether the opponent should Mega Evolve.
        /// </summary>
        /// <returns>True if Mega Evolution should occur, otherwise false.</returns>
        bool pbEnemyShouldMegaEvolve();
    }
}