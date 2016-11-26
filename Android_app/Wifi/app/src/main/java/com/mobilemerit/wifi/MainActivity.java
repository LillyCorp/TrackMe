package com.mobilemerit.wifi;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiManager;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

import com.mobilemerit.adapter.ListAdapter;
import com.mobilemerit.javafiles.ImportDialog;
import com.mobilemerit.wifi.R;

import org.w3c.dom.Text;

public class MainActivity extends Activity {
	//Button setWifi;
	WifiManager wifiManager;
	WifiReceiver receiverWifi;
	List<ScanResult> wifiList;
	List<String> listOfProvider;
	//ListAdapter adapter;
	//ListView listViwProvider;
	String namewifi;
	TextView dist;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_main);

		listOfProvider = new ArrayList<String>();
		namewifi = getIntent().getStringExtra("wifin");

		dist = (TextView) findViewById(R.id.dist);
		/*setting the resources in class*/
		//listViwProvider = (ListView) findViewById(R.id.list_view_wifi);
		//setWifi = (Button) findViewById(R.id.btn_wifi);
		
		//setWifi.setOnClickListener(this);
		wifiManager = (WifiManager) this.getSystemService(Context.WIFI_SERVICE);
		/*checking wifi connection
		 * if wifi is on searching available wifi provider*/


		if (wifiManager.isWifiEnabled() == true) {
			//setWifi.setText("ON");
			scaning();
		}
		else {

			Toast.makeText(MainActivity.this,"Switch on your wifi!",Toast.LENGTH_SHORT).show();
		}
		/*opening a detail dialog of provider on click   */
		/*listViwProvider.setOnItemClickListener(new AdapterView.OnItemClickListener() {
			@Override
			public void onItemClick(AdapterView<?> parent, View view,
					int position, long id) {
					ImportDialog action = new ImportDialog(MainActivity.this, (wifiList.get(position)).toString());
					action.showDialog();
			}
		});*/


	}

	private void scaning() {

		// wifi scaned value broadcast receiver
		receiverWifi = new WifiReceiver();
		// Register broadcast receiver
		// Broacast receiver will automatically call when number of wifi
		// connections changed
		registerReceiver(receiverWifi, new IntentFilter(
				WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
		wifiManager.startScan();
		
	}

	/*setting the functionality of ON/OFF button*/
	/*@Override
	public void onClick(View arg0) {
		//if wifi is ON set it OFF and set button text "OFF"
		if (wifiManager.isWifiEnabled() == true) {
			wifiManager.setWifiEnabled(false);
			setWifi.setText("OFF");
			listViwProvider.setVisibility(ListView.GONE);
		} 
		// if wifi is OFF set it ON
		//set button text "ON"
		//and scan available wifi provider
		else if (wifiManager.isWifiEnabled() == false) {
			wifiManager.setWifiEnabled(true);
			setWifi.setText("ON");
			listViwProvider.setVisibility(ListView.VISIBLE);
			scaning();
		}
	}*/

	protected void onPause() {
		super.onPause();
		unregisterReceiver(receiverWifi);
	}

	protected void onResume() {
		registerReceiver(receiverWifi, new IntentFilter(
				WifiManager.SCAN_RESULTS_AVAILABLE_ACTION));
		super.onResume();
	}

	class WifiReceiver extends BroadcastReceiver {

		// This method call when number of wifi connections changed
		public void onReceive(Context c, Intent intent) {
			wifiList = wifiManager.getScanResults();
			
			/* sorting of wifi provider based on level */
			Collections.sort(wifiList, new Comparator<ScanResult>() {
				@Override
				public int compare(ScanResult lhs, ScanResult rhs) {
					return (lhs.level > rhs.level ? -1
							: (lhs.level == rhs.level ? 0 : 1));
				}
			});
			listOfProvider.clear();
			//adapter.clear();
			String providerName;
			for (int i = 0; i < wifiList.size(); i++) {
				/* to get SSID and BSSID of wifi provider*/

				double d = (27.55 - (20 * Math.log10(2412)) + Math.abs(wifiList.get(i).level)) / 20.0;
				double exp = Math.pow(10.0, d);
				providerName = (wifiList.get(i).SSID).toString() + "\n" + Double.toString(exp) + " m";
				//System.out.println(wifiList.get(i).level);
				if ((wifiList.get(i).SSID).toString().equalsIgnoreCase(namewifi)) {
					listOfProvider.add(providerName);
				}
			}
			/*setting list of all wifi provider in a List*/
			//adapter = new ListAdapter(MainActivity.this, listOfProvider);
			//listViwProvider.setAdapter(adapter);

			//adapter.notifyDataSetChanged();

			dist.setText(listOfProvider.get(0));

		}
	}
}
