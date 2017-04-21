using System;
using System.IO;
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

namespace ClassicListExporter
{
    /// <summary>
    /// Interaction logic for ListPickerWindow.xaml
    /// </summary>
    public partial class ListPickerWindow : Window
    {
        DataSet listData = new DataSet();
        DatabaseManager db;

        public ListPickerWindow(string fileName)
        {
            InitializeComponent();
            db = new DatabaseManager(fileName);
            listData = db.getLists();
            listListView.DataContext = listData.Tables[0].DefaultView;
        }

        protected override void OnContentRendered(EventArgs e)
        {
            base.OnContentRendered(e);
            if (listData.Tables[0].DefaultView.Count == 0)
            {
                MessageBox.Show("There are no lists in this backup!");
                this.Close();
            }
        }

        private void listListView_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            string id = listData.Tables[0].DefaultView[listListView.SelectedIndex]["id"].ToString();
            string name = listData.Tables[0].DefaultView[listListView.SelectedIndex]["name"].ToString();
            ListNameWindow nameWindow = new ListNameWindow(id,name,db);
            nameWindow.ShowDialog();
            this.Close();
        }
    }
}
