using System;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Net.Mime;
using System.Text;
using System.Xml.Linq;
using CitizenFX.Core;

namespace ZentryCSharp_Utils.Server.Events {
    public class JsonApi {
        public JsonApi(string url) {
            using (var client = new WebClient()) {
                Debug.WriteLine(url);
                string xml = client.DownloadString(url);
                Debug.WriteLine(xml);

                XDocument doc = XDocument.Parse(xml);
                
                
            }
        }
    }
}