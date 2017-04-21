using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using System.Data.SQLite;
using System.Data;
using System.Threading;

namespace ClassicListExporter
{
    /// <summary>
    /// Interaction logic for ListNameWindow.xaml
    /// </summary>
    public partial class ListNameWindow : Window
    {
        string id;
        DatabaseManager db;
        public ListNameWindow(string id, string name, DatabaseManager db)
        {
            InitializeComponent();
            this.id = id;
            this.db = db;
            nameTextBox.Text = name;
        }

        async private void Button_Click(object sender, RoutedEventArgs e)
        {
            Window window = new Window()
            {
                WindowStyle = WindowStyle.None,
                WindowState = System.Windows.WindowState.Maximized,
                Background = System.Windows.Media.Brushes.Transparent,
                AllowsTransparency = true,
                ShowInTaskbar = false,
                ShowActivated = true,
                Topmost = true
            };

            window.Show();
            var listName = nameTextBox.Text;
            ThreadPool.QueueUserWorkItem(async (state) =>
            {
                var caches = db.getCaches(id);
                var cacheArray = new List<string>();
                foreach (DataRowView row in caches.Tables[0].DefaultView)
                {
                    cacheArray.Add(row["cacheCode"].ToString());
                }
                var service = new ListDataService(db.token);
                var listId = await service.CreateList(listName);
                var result = await service.AddToList(listId, cacheArray);
                
                Dispatcher.Invoke(() =>
                {
                    window.Close();
                    MessageBox.Show(window, "List Exported");
                    this.Close();
                });

            });
            var res = MessageBox.Show(window, "Exporting List...");
            
        }
    }
}
