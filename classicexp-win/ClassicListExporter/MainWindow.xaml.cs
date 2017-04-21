using Microsoft.Win32;
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
using System.Windows.Navigation;
using WPFFolderBrowser;
using PList;

namespace ClassicListExporter
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        List<Tuple<string, string, string>> availableBackups = new List<Tuple<string, string, string>>();
        public MainWindow()
        {
            InitializeComponent();
            try
            {
                var backupFolder = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Apple Computer\\MobileSync\\Backup");
                var files = Directory.GetDirectories(backupFolder);
                foreach (string file in files)
                {
                    var infoPath = Path.Combine(file, "Info.plist");
                    var plist = PListRoot.Load(infoPath).Root as PListDict;
                    var apps = plist["Installed Applications"] as PListArray;
                    if (apps.Contains(new PListString("MZCZ5SMF8U.iCacher")))
                    {
                        var date = plist["Last Backup Date"] as PListDate;
                        var name = plist["Display Name"] as PListString;
                        availableBackups.Add(new Tuple<string, string, string>(date.Value.ToShortDateString(), name.Value, file));
                    }

                }
            } catch (Exception e)
            {
                MessageBox.Show("Unable to find iTunes backup folder. You must make an unencrypted backup of your device using iTunes before running this application.");
            }
            backupListView.DataContext = availableBackups;
            //selectListButton.IsEnabled = true;
        }

        private void Button_Click(object sender, RoutedEventArgs e)
        {
            ListPickerWindow listPicker = new ListPickerWindow(availableBackups[backupListView.SelectedIndex].Item3);
            listPicker.ShowDialog();

        }

        private void backupListView_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            selectListButton.IsEnabled = backupListView.SelectedIndex != -1;
            ExportWaypointsButton.IsEnabled = backupListView.SelectedIndex != -1;
        }

        private void ExportWaypointsButton_Click(object sender, RoutedEventArgs e)
        {
            WaypointPickerWindow waypointPicker = new WaypointPickerWindow(availableBackups[backupListView.SelectedIndex].Item3);
            waypointPicker.ShowDialog();
        }
    }
}
