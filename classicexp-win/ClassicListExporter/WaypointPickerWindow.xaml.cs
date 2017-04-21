using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using Gat;
using Gat.Controls;
using System.Reflection;

namespace ClassicListExporter
{

    public static class MyExtensions
    {
        public static void AutoClose(this MessageBoxViewModel vm)
        {
            // I feel dirty.
            MethodInfo dynMethod = vm.GetType().GetMethod("Close",
    BindingFlags.NonPublic | BindingFlags.Instance);
            dynMethod.Invoke(vm, null);
        }
    }
    /// <summary>
    /// Interaction logic for WaypointPickerWindow.xaml
    /// </summary>
    public partial class WaypointPickerWindow : Window
    {
        List<WaypointItem> waypointList;
        DatabaseManager db;

        public WaypointPickerWindow(string fileName)
        {
            InitializeComponent();
            db = new DatabaseManager(fileName);
            waypointList = db.getWaypoints();
            WaypointListView.DataContext = waypointList;
        }

        protected override void OnContentRendered(EventArgs e)
        {
            base.OnContentRendered(e);
            if (waypointList.Count == 0)
            {
                MessageBox.Show("There are no waypoints in this backup!");
                this.Close();
            }
        }

        async private void Button_Click(object sender, RoutedEventArgs e)
        {
            var service = new ListDataService(db.token);
            var selectedWaypoints = waypointList.FindAll(s => s.IsSelected);
            var totalSecs = selectedWaypoints.Count * 2;
            var mins = totalSecs / 60;
            var secs = totalSecs % 60;

            var messageBox = new Gat.Controls.MessageBoxView();
            var vm = (Gat.Controls.MessageBoxViewModel)messageBox.FindResource("ViewModel");

            var cancelled = false;
            ThreadPool.QueueUserWorkItem(async (state) =>
            {
                foreach (var waypoint in selectedWaypoints)
                {
                    if (cancelled) break;
                    var result = await service.AddWaypoint(waypoint);
                    await Task.Delay(2000);
                }
                Dispatcher.Invoke(() =>
                {
                    vm.AutoClose();
                });
               
            });
            

            vm.Message = $"Exporting waypoints. This will take approx. {mins} minutes and {secs} seconds...";


            vm.OkVisibility = false;
            vm.CancelVisibility = true;
            vm.YesVisibility = false;
            vm.NoVisibility = false;

            vm.Show();
           
            cancelled = true;
           
           
        }
    }
}
