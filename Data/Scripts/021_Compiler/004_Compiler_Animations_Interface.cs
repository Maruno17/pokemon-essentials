using System;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Interface for battle animation compilation system.
    /// Handles compilation of battle animations from source files to runtime format.
    /// </summary>
    public interface ICompilerAnimation
    {
        /// <summary>
        /// Compiles all battle animations from source files.
        /// Processes animation data files and converts them to runtime format.
        /// </summary>
        void CompileAllAnimations();

        /// <summary>
        /// Compiles move animations from move animation files.
        /// Processes individual move animation data and effects.
        /// </summary>
        void CompileMoveAnimations();

        /// <summary>
        /// Compiles common battle animations (status effects, weather, etc.).
        /// Processes shared animation data used across multiple moves and effects.
        /// </summary>
        void CompileCommonAnimations();

        /// <summary>
        /// Compiles Pokemon sprites and animation data.
        /// Processes Pokemon front/back sprites and their animation frames.
        /// </summary>
        void CompilePokemonAnimations();

        /// <summary>
        /// Compiles trainer sprites and animation data.
        /// Processes trainer sprites and their throw animations.
        /// </summary>
        void CompileTrainerAnimations();

        /// <summary>
        /// Compiles battlefield background animations.
        /// Processes battle background sprites and their animated elements.
        /// </summary>
        void CompileBattlefieldAnimations();

        /// <summary>
        /// Validates that all required animation files are present and properly formatted.
        /// </summary>
        /// <returns>True if all animations are valid, false otherwise.</returns>
        bool ValidateAnimations();

        /// <summary>
        /// Gets compilation statistics for animation processing.
        /// </summary>
        /// <returns>Dictionary containing animation compilation statistics.</returns>
        IDictionary<string, object> GetAnimationStats();
    }

    /// <summary>
    /// Interface for animation data parsing and processing.
    /// Handles parsing of animation definition files and sprite data.
    /// </summary>
    public interface IAnimationDataParser
    {
        /// <summary>
        /// Parses animation definition files and extracts animation data.
        /// </summary>
        /// <param name="filename">The animation file to parse.</param>
        /// <returns>Parsed animation data structure.</returns>
        IDictionary<string, object> ParseAnimationFile(string filename);

        /// <summary>
        /// Parses timing data for animation frames and effects.
        /// </summary>
        /// <param name="timingData">The timing data to parse.</param>
        /// <returns>Processed timing information for animation playback.</returns>
        IList<object> ParseTimingData(string timingData);

        /// <summary>
        /// Parses animation effect parameters and settings.
        /// </summary>
        /// <param name="effectData">The effect data to parse.</param>
        /// <returns>Processed effect parameters.</returns>
        IDictionary<string, object> ParseEffectData(string effectData);

        /// <summary>
        /// Parses sprite animation frames and sequences.
        /// </summary>
        /// <param name="frameData">The frame data to parse.</param>
        /// <returns>Processed frame sequence information.</returns>
        IList<object> ParseFrameData(string frameData);

        /// <summary>
        /// Validates animation data structure and content.
        /// </summary>
        /// <param name="animationData">The animation data to validate.</param>
        /// <param name="animationType">The type of animation being validated.</param>
        /// <returns>True if animation data is valid, false otherwise.</returns>
        bool ValidateAnimationData(IDictionary<string, object> animationData, string animationType);
    }

    /// <summary>
    /// Interface for sprite processing and optimization.
    /// Handles processing of sprite graphics for animations.
    /// </summary>
    public interface ISpriteProcessor
    {
        /// <summary>
        /// Processes sprite files for optimal loading and display.
        /// Optimizes sprite graphics for runtime performance.
        /// </summary>
        /// <param name="spriteFilename">The sprite file to process.</param>
        /// <param name="outputPath">The output path for processed sprite.</param>
        void ProcessSprite(string spriteFilename, string outputPath);

        /// <summary>
        /// Generates sprite frames from sprite sheets.
        /// Extracts individual frames from larger sprite sheet images.
        /// </summary>
        /// <param name="spriteSheet">The sprite sheet to process.</param>
        /// <param name="frameWidth">Width of each frame in pixels.</param>
        /// <param name="frameHeight">Height of each frame in pixels.</param>
        /// <returns>List of individual sprite frames.</returns>
        IList<object> GenerateSpriteFrames(string spriteSheet, int frameWidth, int frameHeight);

        /// <summary>
        /// Optimizes sprite files for memory usage and loading speed.
        /// </summary>
        /// <param name="spriteData">The sprite data to optimize.</param>
        /// <param name="compressionLevel">The compression level to apply.</param>
        /// <returns>Optimized sprite data.</returns>
        object OptimizeSprite(object spriteData, int compressionLevel);

        /// <summary>
        /// Validates sprite file format and integrity.
        /// </summary>
        /// <param name="spriteFilename">The sprite file to validate.</param>
        /// <returns>True if sprite is valid, false otherwise.</returns>
        bool ValidateSpriteFile(string spriteFilename);

        /// <summary>
        /// Gets metadata information about sprite files.
        /// </summary>
        /// <param name="spriteFilename">The sprite file to analyze.</param>
        /// <returns>Dictionary containing sprite metadata.</returns>
        IDictionary<string, object> GetSpriteMetadata(string spriteFilename);
    }

    /// <summary>
    /// Interface for animation compilation output and serialization.
    /// Handles output of compiled animation data to runtime format.
    /// </summary>
    public interface IAnimationCompilerOutput
    {
        /// <summary>
        /// Writes compiled animation data to output files.
        /// </summary>
        /// <param name="animationType">The type of animation data.</param>
        /// <param name="compiledData">The compiled animation data.</param>
        /// <param name="outputPath">The output file path.</param>
        void WriteAnimationData(string animationType, object compiledData, string outputPath);

        /// <summary>
        /// Serializes animation data for runtime loading.
        /// </summary>
        /// <param name="animationData">The animation data to serialize.</param>
        /// <param name="format">The serialization format to use.</param>
        /// <returns>Serialized animation data.</returns>
        byte[] SerializeAnimationData(object animationData, string format);

        /// <summary>
        /// Creates compressed animation archives for distribution.
        /// </summary>
        /// <param name="animationFiles">List of animation files to archive.</param>
        /// <param name="archivePath">The output archive path.</param>
        void CreateAnimationArchive(IList<string> animationFiles, string archivePath);

        /// <summary>
        /// Generates animation index files for fast loading.
        /// </summary>
        /// <param name="compiledAnimations">The compiled animation data.</param>
        /// <returns>Animation index data for quick lookup.</returns>
        IDictionary<string, object> GenerateAnimationIndex(IDictionary<string, object> compiledAnimations);

        /// <summary>
        /// Backs up existing animation data before overwriting.
        /// </summary>
        /// <param name="animationDataPath">The animation data path to backup.</param>
        void BackupAnimationData(string animationDataPath);
    }

    /// <summary>
    /// Interface for animation timing and synchronization.
    /// Handles timing calculations for animation playback.
    /// </summary>
    public interface IAnimationTiming
    {
        /// <summary>
        /// Calculates frame timing for smooth animation playback.
        /// </summary>
        /// <param name="frameCount">Total number of frames in animation.</param>
        /// <param name="duration">Total duration of animation in seconds.</param>
        /// <returns>Array of frame timing values.</returns>
        double[] CalculateFrameTiming(int frameCount, double duration);

        /// <summary>
        /// Synchronizes animation timing with battle speed settings.
        /// </summary>
        /// <param name="baseTiming">The base animation timing.</param>
        /// <param name="speedMultiplier">Battle speed multiplier.</param>
        /// <returns>Adjusted timing for current speed setting.</returns>
        double[] AdjustTimingForSpeed(double[] baseTiming, double speedMultiplier);

        /// <summary>
        /// Validates animation timing for consistency and performance.
        /// </summary>
        /// <param name="timingData">The timing data to validate.</param>
        /// <returns>True if timing is valid, false otherwise.</returns>
        bool ValidateAnimationTiming(double[] timingData);

        /// <summary>
        /// Optimizes animation timing for target frame rate.
        /// </summary>
        /// <param name="timingData">The timing data to optimize.</param>
        /// <param name="targetFPS">Target frames per second.</param>
        /// <returns>Optimized timing data.</returns>
        double[] OptimizeTimingForFrameRate(double[] timingData, int targetFPS);
    }

    /// <summary>
    /// Interface for animation effect processing.
    /// Handles compilation of visual effects used in battle animations.
    /// </summary>
    public interface IAnimationEffectProcessor
    {
        /// <summary>
        /// Processes particle effect definitions for animations.
        /// </summary>
        /// <param name="effectDefinition">The particle effect definition.</param>
        /// <returns>Compiled particle effect data.</returns>
        object ProcessParticleEffect(IDictionary<string, object> effectDefinition);

        /// <summary>
        /// Processes screen flash and tint effects.
        /// </summary>
        /// <param name="flashDefinition">The flash effect definition.</param>
        /// <returns>Compiled flash effect data.</returns>
        object ProcessFlashEffect(IDictionary<string, object> flashDefinition);

        /// <summary>
        /// Processes sound effect synchronization with animations.
        /// </summary>
        /// <param name="soundEffects">List of sound effects to synchronize.</param>
        /// <param name="animationTiming">The animation timing data.</param>
        /// <returns>Synchronized sound effect data.</returns>
        object ProcessSoundEffects(IList<object> soundEffects, double[] animationTiming);

        /// <summary>
        /// Validates effect definitions and parameters.
        /// </summary>
        /// <param name="effectData">The effect data to validate.</param>
        /// <param name="effectType">The type of effect being validated.</param>
        /// <returns>True if effect is valid, false otherwise.</returns>
        bool ValidateEffect(IDictionary<string, object> effectData, string effectType);
    }
}