using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data.SQLite;
using System.Data;
using System.IO;
using PList;
using zlib;

namespace ClassicListExporter
{
    public class WaypointItem
    {
        public string name, cacheCode;
        public Double lat, lon;
        public bool IsSelected { get; set; }
        public string waypointDescription
        {
            get { return "Cache :" + cacheCode + " Name: " + name;  }
        }
    }

   public class DatabaseManager
    {
        public string token;
        protected SQLiteConnection conn;
       public DatabaseManager(string backupDir)
        {
            try
            {
                var manifestPath = Path.Combine(backupDir, "Manifest.db");
                var manifestConn = new SQLiteConnection("Data Source=" + manifestPath + ";Version=3;");
                manifestConn.Open();
                DataSet mData = new DataSet();
                string sql = "select fileId from Files where relativePath = \"Library/Preferences/MZCZ5SMF8U.iCacher.plist\"";
                SQLiteCommand command = new SQLiteCommand(sql, manifestConn);
                SQLiteDataAdapter DB = new SQLiteDataAdapter(command.CommandText, manifestConn);
                DB.Fill(mData);
                var fileId = mData.Tables[0].DefaultView[0]["fileId"].ToString();
                var prefix = fileId.Substring(0, 2);
                var infoPath = Path.Combine(backupDir, prefix, fileId);
                //var infoPath = "C:\\Users\\Casey Cady\\Documents\\Documents\\cindy.plist";
                var plist = PListRoot.Load(infoPath).Root as PListDict;
                token = (plist["GEOGlobals_mApiAccessToken"] as PListString).Value;
                var guid = (plist["GEOGlobals_mLoggedInUserGuid"] as PListString).Value;
                sql = "select fileId from Files where domain = \"AppDomain-MZCZ5SMF8U.iCacher\" and relativePath = \"Documents/" + guid + ".db\"";
                command = new SQLiteCommand(sql, manifestConn);
                DB = new SQLiteDataAdapter(command.CommandText, manifestConn);
                mData = new DataSet();
                DB.Fill(mData);
                fileId = mData.Tables[0].DefaultView[0]["fileId"].ToString();
                prefix = fileId.Substring(0, 2);
                var dbPath = Path.Combine(backupDir, prefix, fileId);
                // var dbPath = "C:\\Users\\Casey Cady\\Documents\\Documents\\cindy2.db";
                conn = new SQLiteConnection("Data Source=" + dbPath + ";Version=3;");
                conn.Open();
                manifestConn.Close();
            } catch (Exception e)
            {
                System.Windows.MessageBox.Show(e.ToString());
            }
        }


        ~DatabaseManager()
        {
            //conn.Close();
        }

        public DataSet getLists()
        {
            string sql = "SELECT l.name as name, l.id as id, COUNT(c.id) AS cacheCount from geocacheToGroupV3 c left join groupsV3 l on c.groupId = l.id group by l.name";
            SQLiteCommand command = new SQLiteCommand(sql, conn);
            SQLiteDataAdapter DB = new SQLiteDataAdapter(command.CommandText, conn);
            var listData = new DataSet();
            DB.Fill(listData);
            return listData;
        }

        public DataSet getCaches(string id)
        {
            string sql = "SELECT cacheCode from geocacheToGroupV3 where groupId=\"" + id + "\";";
            SQLiteCommand command = new SQLiteCommand(sql, conn);
            SQLiteDataAdapter DB = new SQLiteDataAdapter(command.CommandText, conn);
            DataSet caches = new DataSet();
            DB.Fill(caches);
            return caches;
        }

        private PListDict decompressPlist(string encodedPList)
        {
            var data = Convert.FromBase64String(encodedPList);
            var z = new ZStream();
            MemoryStream oInStream = new MemoryStream(data);
            MemoryStream oOutStream = new MemoryStream();
            var zIn = new ZInputStream(oInStream);
            byte[] buffer = new byte[2000];
            int len;
            while ((len = zIn.read(buffer, 0, 2000)) > 0)
            {
                oOutStream.Write(buffer, 0, len);
            }
            oOutStream.Flush();
            zIn.Close();

            var plist = PListRoot.Load(oOutStream).Root as PListDict;
            oOutStream.Close();

            return plist;
        }

        public List<WaypointItem> getWaypoints()
        {
            var waypoints = new List<WaypointItem>();
            string sql = "SELECT cacheCode, body from userWaypointsV3;";
            SQLiteCommand command = new SQLiteCommand(sql, conn);
            SQLiteDataAdapter DB = new SQLiteDataAdapter(command.CommandText, conn);
            DataSet wptRows = new DataSet();
            DB.Fill(wptRows);
            foreach (DataRowView row in wptRows.Tables[0].DefaultView)
            {
                var item = new WaypointItem();
                item.cacheCode = row["cacheCode"].ToString();
                var plist = decompressPlist(row["body"].ToString());
                foreach (var plistItem in plist["mRecordByAddress"] as PListDict)
                {
                    var waypointDict = plistItem.Value as PListDict;
                    if (waypointDict.ContainsKey("mLatitude"))
                    {
                        item.name = (waypointDict["mName"] as PListString).Value;
                        item.lat = (waypointDict["mLatitude"] as PListReal).Value;
                        item.lon = (waypointDict["mLongitude"] as PListReal).Value;
                        item.IsSelected = false;
                        waypoints.Add(item);
                        break;
                    }
                }

            }
            return waypoints; 
        }
    }
}
