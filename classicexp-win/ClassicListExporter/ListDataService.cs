using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net.Http;
using System.Net.Http.Headers;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

namespace ClassicListExporter
{
    class ListDataService
    {
        const string CreateUrl = "https://api.groundspeak.com/mobile/v1/lists";
        const string AddUrl = "https://api.groundspeak.com/mobile/v1/lists/";
        const string AddWaypointUrl = "https://api.groundspeak.com/LiveV6/Geocaching.svc/internal/SaveUserWaypoint?format=json";

        string token;

        public ListDataService(string token)
        {
            this.token = token;
        }

        private HttpClient GetClient()
        {
            HttpClient client = new HttpClient();
            client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
            client.DefaultRequestHeaders.Add("Authorization", "bearer " + token);
            return client;
        }

        /* {
  "type": {
    "id": 0,
    "code": "string"
  },
  "name": "string",
  "description": "string",
  "isPublic": true,
  "isShared": true
}*/
    public async Task<string> CreateList(String name)
        {
            using (HttpClient client = GetClient())
            {
                try
                {
                    String fullUrl = CreateUrl;
                    var requestDict = new { type = new { id = 2, code="bm" }, name=name };
                    var requestJSON = JObject.FromObject(requestDict);
                   // StringContent reqContent = new HttpContent()
                    StringContent reqContent = new StringContent(requestJSON.ToString(), Encoding.UTF8, "application/json");
                   // reqContent.Headers.Add("Authorization", "bearer " + "f0df18ab-d306-4f0f-b1da-502ce6a8f17e");
                    HttpResponseMessage responseMessage = await client.PostAsync(fullUrl, reqContent);
 
                    responseMessage.EnsureSuccessStatusCode();
                    string content = await responseMessage.Content.ReadAsStringAsync();
                    //content = content.Trim('"');
                    JObject json = JObject.Parse(content);
                    return json["referenceCode"].ToString();
                }
                catch (Exception e)
                {
                    return null;
                }
            }
        }

        public async Task<bool> AddWaypoint(WaypointItem waypoint)
        {
            using (HttpClient client = GetClient())
            {
                try
                {
                    String fullUrl = AddWaypointUrl;
                   
                    var requestDict = new { AccessToken = token,
                        CacheCode = waypoint.cacheCode,
                        Latitude = waypoint.lat,
                        Longitude = waypoint.lon,
                        Description = waypoint.name,
                        IsCorrectedCoordinate = false,
                        IsUserCompleted = false };
                    var requestJSON = JObject.FromObject(requestDict);
                    // StringContent reqContent = new HttpContent()
                 
                    StringContent reqContent = new StringContent(requestJSON.ToString(), Encoding.UTF8, "application/json");
                    // reqContent.Headers.Add("Authorization", "bearer " + "f0df18ab-d306-4f0f-b1da-502ce6a8f17e");
                    HttpResponseMessage responseMessage = await client.PostAsync(fullUrl, reqContent);

                    responseMessage.EnsureSuccessStatusCode();
                    string content = await responseMessage.Content.ReadAsStringAsync();
                    //content = content.Trim('"');
                    System.Console.WriteLine(content);
                    //JObject json = JObject.Parse(content);
                    return true;
                }
                catch (Exception e)
                {
                    return false;
                }
            }
        }

        public async Task<bool> AddToList(String id, List<string> cacheIds)
        {
            var reqArray = new JArray();
            foreach (string cache in cacheIds) 
            {
                var itemDict = new JObject(new JProperty("referenceCode", cache));
                reqArray.Add(itemDict);
            }
            using (HttpClient client = GetClient())
            {
                try
                {
                    String fullUrl = AddUrl+id+ "/bulkaddgeocaches";
                    StringContent reqContent = new StringContent(reqArray.ToString(), Encoding.UTF8, "application/json");
                    //reqContent.Headers.Add("Authorization", "bearer " + "f0df18ab-d306-4f0f-b1da-502ce6a8f17e");
                    HttpResponseMessage responseMessage = await client.PutAsync(fullUrl, reqContent);

                    responseMessage.EnsureSuccessStatusCode();
                    string content = await responseMessage.Content.ReadAsStringAsync();
                    //content = content.Trim('"');
                    JObject json = JObject.Parse(content);
                    return true;
                }
                catch (Exception e)
                {
                    return false;
                }
            }
        }
    }

    
}
