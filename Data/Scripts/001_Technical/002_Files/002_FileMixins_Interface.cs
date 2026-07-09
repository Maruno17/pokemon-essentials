using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Mixin interface for binary file reading capabilities (FileInputMixin).
    /// </summary>
    public interface IFileInputMixin
    {
        /// <summary>
        /// Reads a single byte from the input stream.
        /// </summary>
        int fgetb();

        /// <summary>
        /// Reads a 16-bit word (2 bytes) from the input stream in little-endian format.
        /// </summary>
        int fgetw();

        /// <summary>
        /// Reads a 32-bit double word (4 bytes) from the input stream in little-endian format.
        /// </summary>
        int fgetdw();

        /// <summary>
        /// Reads a signed byte from the input stream.
        /// </summary>
        int fgetsb();

        /// <summary>
        /// Reads a single byte from a specific offset in the file.
        /// </summary>
        int xfgetb(long offset);

        /// <summary>
        /// Reads a 16-bit word from a specific offset in the file.
        /// </summary>
        int xfgetw(long offset);

        /// <summary>
        /// Reads a 32-bit double word from a specific offset in the file.
        /// </summary>
        int xfgetdw(long offset);

        /// <summary>
        /// Gets the file offset for a specific index.
        /// </summary>
        int getOffset(int index);

        /// <summary>
        /// Gets the data length for a specific index.
        /// </summary>
        int getLength(int index);

        /// <summary>
        /// Reads a name string for a specific index.
        /// </summary>
        string readName(int index);

        /// <summary>
        /// Sets the file to binary mode.
        /// </summary>
        void binmode();

        /// <summary>
        /// Gets or sets the current position in the file stream.
        /// </summary>
        int pos { get; set; }

        /// <summary>
        /// Reads a specified number of bytes from the current position.
        /// </summary>
        string read(int length);

        /// <summary>
        /// Iterates through each byte.
        /// </summary>
        void each_byte(Action<byte> @yield);
    }

    /// <summary>
    /// Mixin interface for binary file writing capabilities (FileOutputMixin).
    /// </summary>
    public interface IFileOutputMixin
    {
        /// <summary>
        /// Writes a single byte to the output stream.
        /// </summary>
        void fputb(int b);

        /// <summary>
        /// Writes a 16-bit word (2 bytes) in little-endian format.
        /// </summary>
        void fputw(int w);

        /// <summary>
        /// Writes a 32-bit double word (4 bytes) in little-endian format.
        /// </summary>
        void fputdw(int w);

        /// <summary>
        /// Writes data to the output stream.
        /// </summary>
        void write(string data);
    }

    /// <summary>
    /// Interface for enhanced File class with input and output mixins.
    /// </summary>
    public interface IFile : IFileInputMixin, IFileOutputMixin
    {
    }

    /// <summary>
    /// Interface for string input with file input mixin capabilities (StringInput class).
    /// </summary>
    public interface IStringInputFileMixin : IStringInput, IFileInputMixin
    {
        /// <summary>
        /// Checks if the stream is closed.
        /// </summary>
        //bool closed();

        /// <summary>
        /// Gets the current character at the position and advances.
        /// </summary>
        //string getc();

        /// <summary>
        /// Checks if the string input is at end of file.
        /// </summary>
        //bool eof();
    }

    /// <summary>
    /// Interface for string output with file output mixin capabilities (StringOutput class).
    /// </summary>
    public interface IStringOutput : IFileOutputMixin
    {
    }
}