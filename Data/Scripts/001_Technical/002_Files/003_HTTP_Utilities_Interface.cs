using System;
using System.Collections;
using System.Collections.Generic;

namespace PokemonEssentials
{
    /// <summary>
    /// Extension interface for HTTP utility functions (IMain interface).
    /// </summary>
    public interface IMainHTTPUtilities : IMain
    {
        /// <summary>
        /// Sends HTTP POST data to a URL with form-encoded content.
        /// </summary>
        string pbPostData(string url, IDictionary<string, object> postdata, string filename = null, int depth = 0);

        /// <summary>
        /// Downloads data from a URL using HTTP GET request.
        /// </summary>
        string pbDownloadData(string url, string filename = null, string authorization = null, int depth = 0, Action<byte[]> @yield = null);

        /// <summary>
        /// Downloads content from a URL and returns it as a string.
        /// </summary>
        string pbDownloadToString(string url);

        /// <summary>
        /// Downloads content from a URL and saves it to a file.
        /// </summary>
        void pbDownloadToFile(string url, string file);

        /// <summary>
        /// Sends HTTP POST data to a URL and returns the response as a string.
        /// </summary>
        string pbPostToString(string url, IDictionary<string, object> postdata);

        /// <summary>
        /// Sends HTTP POST data to a URL and saves the response to a file.
        /// </summary>
        void pbPostToFile(string url, IDictionary<string, object> postdata, string file);
    }

    /// <summary>
    /// Interface for lightweight HTTP client operations (HTTPLite module).
    /// </summary>
    public interface IHTTPLite
    {
        /// <summary>
        /// Sends an HTTP POST request with the specified body and headers.
        /// </summary>
        object post_body(string url, string body, string contentType, IDictionary<string, string> headers);

        /// <summary>
        /// Sends an HTTP GET request with the specified headers.
        /// </summary>
        object get(string url, IDictionary<string, string> headers);
    }
}