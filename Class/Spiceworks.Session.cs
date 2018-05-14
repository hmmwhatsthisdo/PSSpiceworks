using System;
using Microsoft.PowerShell.Commands;

namespace Spiceworks {
    public class Session {
        public Microsoft.PowerShell.Commands.WebRequestSession WebSession;

        public string AuthenticityToken;

        public string Server;

        public bool UseHTTPS;

        public Nullable<int> Port;

        public string Username;

        public System.Uri GetURI(string subpath) {

            var builder = new System.UriBuilder();

            if (this.UseHTTPS) {
                builder.Scheme = "https";
            } else {
                builder.Scheme = "http";
            }

            builder.Host = this.Server;

            if (this.Port.HasValue) {
                builder.Port = this.Port.Value;
            }

            if (subpath != "") {
                builder.Path = subpath;
            }

            return builder.Uri;
        }

        public System.Uri GetURI() {
            return this.GetURI("");
        }
    }
}